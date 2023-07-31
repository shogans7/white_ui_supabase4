// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import * as OneSignal from "https://esm.sh/@onesignal/node-onesignal@1.0.0-beta9";

const _OnesignalAppId_ = Deno.env.get('ONESIGNAL_APP_ID')!
const _OnesignalUserAuthKey_ = Deno.env.get('USER_AUTH_KEY')!
const _OnesignalRestApiKey_ = Deno.env.get('ONESIGNAL_REST_API_KEY')!
const configuration = OneSignal.createConfiguration({
  userKey: _OnesignalUserAuthKey_,
  appKey: _OnesignalRestApiKey_,
})

const onesignal = new OneSignal.DefaultApi(configuration)


serve(async (req) => {
  try {
    const { record } = await req.json()
    console.log(record)

    if(record.deleted_flag == true){
      console.log("TRUE")
      // Build OneSignal notification object
      const notification = new OneSignal.Notification()
      notification.app_id = _OnesignalAppId_
      notification.include_external_user_ids = [record.user_id]
      notification.contents = {
        en: `Your table is booked! Want to know where?`,
      }
      const onesignalApiRes = await onesignal.createNotification(notification)
    
      return new Response(JSON.stringify({ onesignalResponse: onesignalApiRes }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }
  } catch (err) {
    console.error('Failed to create OneSignal notification', err)
    return new Response('Server error.', {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
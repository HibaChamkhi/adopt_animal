# Voice / video calling — spike & plan (E3-4 / E4-4)

## Current state (shipped)
The vet chat and vet profile have a **call button** that launches the device dialer
via `tel:` (`url_launcher`). This is **Phase 1 voice** and works today with no
backend — it places a normal phone call to the vet's number.

## The question
Add **in-app** voice/video calling (talk to a vet inside the app, no PSTN call).

## Options compared

| Option | Model | Setup effort | Needs backend | Notes |
|---|---|---|---|---|
| **Agora** | Managed RTC SDK | Low–Medium | Token server | Generous free tier (10k min/mo), great Flutter SDK, low-latency video |
| **Twilio Video/Voice** | Managed | Medium | Token + TwiML server | Mature, more expensive, strong docs |
| **100ms** | Managed RTC | Low | Token server | Simple Flutter SDK, good free tier |
| **Raw WebRTC** | Self-hosted | High | Signaling + STUN/TURN | Cheapest at scale, most work (build signaling, run TURN) |

## Recommendation
**Agora** for the first version: lowest effort for high-quality Flutter video, a
free tier big enough for testing/small usage, and you only need a tiny token
endpoint. Revisit raw WebRTC only if call volume makes managed pricing hurt.

## Why this can't ship on the current setup
Managed RTC needs a **token server** to mint per-call credentials (the App
Certificate must stay server-side). That's a **Cloud Function** (Blaze) or any small
backend. You also need an **Agora account** (free) for the App ID.

So in-app calling is **blocked on**: (1) an Agora account/App ID, and (2) a token
endpoint (Cloud Function or backend).

## Integration steps (Agora, when ready)
1. Create an Agora project → get **App ID** and **App Certificate**.
2. Backend (Cloud Function) `agoraToken(channelName, uid)`:
   - Use `agora-token` (RtcTokenBuilder) to return a short-lived RTC token.
3. App:
   ```yaml
   dependencies:
     agora_rtc_engine: ^6.x
     permission_handler: ^11.x
   ```
   - Request mic/camera permission.
   - `createAgoraRtcEngine()` → `initialize(appId)`.
   - Fetch a token from your endpoint for the channel (e.g. `chat_<userId>_<vetId>`).
   - `joinChannel(token, channel, uid)`; render local + remote video views.
4. Signal the callee: write a `calls/{id}` doc (`callerId`, `calleeId`, `channel`,
   `status: ringing`); the vet app listens and shows an incoming-call screen.
   (Real ringing while the app is closed needs push — see `push_notifications.md`,
   also Blaze.)

## App-side changes needed
- A `CallService` (join/leave, token fetch).
- A full-screen call UI (local/remote video, mute, hang up, flip camera).
- An incoming-call listener on a `calls` collection.

## Interim (free) option
Keep the `tel:` dialer for voice, and for "video" offer a **WhatsApp / Google Meet
deep link** to the vet (launch `https://wa.me/<number>` via `url_launcher`) — zero
backend, works now, though it leaves the app.

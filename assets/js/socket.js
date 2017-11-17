// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import { Socket } from "phoenix"
import distanceInWordsToNow from 'date-fns/distance_in_words_to_now'

let socket = new Socket("/socket", { params: { token: window.userToken } })

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("dashboard", {})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully dashboard channel", resp) })
  .receive("error", resp => { console.log("Unable to join dashboard channel", resp) })

channel.on("update_html", payload => {
  document.getElementById("dashboard").innerHTML = payload.html
})


export default socket

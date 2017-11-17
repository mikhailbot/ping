// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import { Socket } from "phoenix"

let socket = new Socket("/socket", { params: { token: window.userToken } })

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("dashboard", {})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully dashboard channel", resp) })
  .receive("error", resp => { console.log("Unable to join dashboard channel", resp) })

channel.on("update_html", payload => {
  console.log(payload)
  // document.getElementById("list-of-hosts").innerHTML = payload.html
  // document.getElementById("last-updated").innerHTML = 'Last updated ' + new Date().toString()
})

export default socket

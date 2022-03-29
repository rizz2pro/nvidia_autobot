# CC Autobuy

# Dependencies: 
- red hat linux(other distro will do but you may have to tinker)
- newman (postman cli) 
- nodejs/npm

# cc_autobuy.sh: 
- Main script. Searches and buys the item

# add_to_cart.sh
- This is run on demand to verify your cookie is valid. Run this and refresh to make sure the item appears in the cart. It's an ethernet cable.

# keepalive.sh: 
- Sends a curl(request) once a minute to keep the cookie alive

# warn_facebook.sh
- Send a notification if our IP was blacklisted and being redirected to facebook

# vpn_switcher.sh (optional)
- Will detect if you are blacklisted and connect to a different VPN server to change your source IP. It will happen automatically so keep this running in a separate terminal.
- I used NordVPN


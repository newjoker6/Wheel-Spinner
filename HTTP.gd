extends Control


var headers = ['x-rapidapi-host: cheapshark-game-deals.p.rapidapi.com',
'x-rapidapi-key: API_KEY_HERE']

var gamesearch: String = "https://cheapshark-game-deals.p.rapidapi.com/games"
var bannersearch:String = "https://cheapshark-game-deals.p.rapidapi.com"
var DealLink:String = "https://www.cheapshark.com/redirect?dealID="

var winnerID
var winnerIMAGE
var winnerDEAL
var winnerPRICE
var winnerSTOREID
var winnerSTORE
var winnerSTOREBANNER



func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	print("request running")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	print(response)
	if not response == []:
		winnerID = response[0]["gameID"]
		winnerIMAGE = response[0]["thumb"]
		winnerDEAL = response[0]["cheapestDealID"]
		winnerPRICE = response[0]["cheapest"]
		download("user://winner.jpg", true, get_parent().get_node("GameImage"), winnerIMAGE)
		print(winnerID)
	else:
		print("This is not a game")


func search_game():
	print(gamesearch + "?title=" + Global.winner.replace(" ","") + "&exact=0&limit=1")
	$HTTPRequest.request(gamesearch + "?title=" + Global.winner.replace(" ","") + "&exact=0&limit=1", headers)



func _on_HTTPDownload_request_completed(result, response_code, headers, body):
	print("Download Complete")


func download(file_name, store_look:bool, obj, ImageLink):
	$HTTPDownload.set_download_file(file_name)
	$HTTPDownload.request(ImageLink)
	yield(get_tree().create_timer(0.5),"timeout")
	create_texture(file_name, obj)
	if store_look == true:
		$HTTPGameLookup.request(gamesearch + "?id=" + str(winnerID), headers)
		yield(get_tree().create_timer(0.5),"timeout")
		$HTTPStoreInfo.request("https://cheapshark-game-deals.p.rapidapi.com/stores", headers)
	


func create_texture(path:String, obj):
	var img = Image.new()
	img.load(path)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	obj.set_texture(tex)


func _on_HTTPGameLookup_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	winnerSTOREID = response["deals"][0]["storeID"]
	print(winnerSTOREID)
	
	


func _on_HTTPStoreInfo_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	prints("STORE DATA: ", response[22].storeName)
	winnerSTORE = response[int(winnerSTOREID) - 1].storeName
	winnerSTOREBANNER = response[int(winnerSTOREID) - 1].images.logo
	print(winnerSTORE)
	yield(get_tree(),"idle_frame")
	Display_Data()
	yield(get_tree(),"idle_frame")


func Display_Data():
	var Details = get_parent().get_node("GameDetails")
	var game = get_parent().get_node("GameImage")
	Details.rect_position.y = game.rect_position.y + game.rect_size.y + 20
	Details.rect_position.x = game.rect_position.x
	Details.bbcode_text = "BEST DEAL!\n\nPrice: $%s\n\nStore: %s\n\nClick [color=teal][url=%s%s]Here[/url][/color] to open this great deal!" %[winnerPRICE, winnerSTORE, DealLink, winnerDEAL]

















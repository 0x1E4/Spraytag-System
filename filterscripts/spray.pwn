/*
	------------------------------------
	Spraytag System (Re-coded by 0x1E4)
	------------------------------------
		It same like this -> https://forum.sa-mp.com/showthread.php?t=499642
		I just recode some parts and it's the same system and same object,
		But my method can be different if you compare my script to that.

		Oh, this is under development and not finished YET!!
		You can see on /releases if you want to download a lastest release.

		Note:
			- Do not download it on main page!!, just head over to /release and download it from there!
			- You can change owner name with MySQL player.
			- You can merge this script with your own gamemode.
			- Use issues page if you found a bug.

	Thank you and enjoy :)

	------------------------------------
	Frequently Asked Question:
	------------------------------------
		Q: Why using EasyDialog instead just using vanilla method?
		A: Nope, EasyDialog make much easier for me to read all dialog route

		Q: I think is not different between the old one with this one.
		A: Yeah i know, i just create with my version :)

		Q: Why using MySQL as database, you can use DoF2 or Dini/Y_INI.
		A: Because with MySQL, everything is much easier storing any data.

		Q: What different between i-zcmd and zcmd?
		A: i-zcmd means improvement zeex command made by Gammix, and he claims that i-zcmd is much faster than old ones.

		Q: can i sell it?
		A: No, you can't sell this script to other people.

		Q: Do you planning to make Dini/Y_INI version?
		A: Yes

		Q: Why you not add some animation after player clicking "Create Tags" ?
		A: Hmm, i didn't plan to putting any animation first, because i want to focus fixing bug.
		   But of course i will make two version at begining release.

	------------------------------------
	Things to you understand the system:
	------------------------------------
		SQL Stuff:
			_H 	(means your SQL hostname (default setting is "localhost"))
			_U  (means your SQL username (default setting is "root"))
			_P  (means your SQL password (default setting is empty or blank text))
			_D  (means your SQL databases (default setting is "test"))

		Variable/Enum:
			sprayID      (represent the mySQL id of each spraytags!)
			sprayExists  (for checking are some tags really exists)
			sprayText    (this where user input a text and manage save or load things)
			sprayOwner   (its just temporarily using player names, you can use SQLID instead using account name)
			sprayColor   (same as sprayText)
			sprayFontN   (font (N)ame)
			sprayFontS   (font (S)ize)
			sprayFontB   (font (B)old)
			sprayObject  (this is where ID of object being created)
			sprayPosX    (manage position X of object)
			sprayPosY    (manage position Y of object)
			sprayPosZ    (manage position Z of object)
			sprayRot     (manage rotation of object)

		Functions:
			try name(arguments) (forward and public functions, yeah you already known it)
			Prepare(arguments)  (mysql_format functions)
			Message(arguments)  (SendClientMessage functions)

	------------------------------------
	Credits:
	------------------------------------
		- Barron for Bare.pwn (or whatever it is :3)
		- pBlueG for a_mysql plugin
		- maddinat0r for sscanf2 (he make some fix on Y_less/Emmet_ version and made sscanf2 as plugin)
		- incognito for streamer
		- Emmet_ for EasyDialog
		- Ino for DialogCenter
		- Emmet_ for concept load and save stuff
		- Zeex/Gammix for i-zcmd
		- 1001font & dafont for all font stuff made by a person who can't i write this one by one :(
*/

//#define FILTERSCRIPT
#define USE_DEBUG_LINE

#include <a_samp>

#if !defined FILTERSCRIPT
	#include <core>
	#include <float>
#endif

#include <a_mysql>
#include <EasyDialog>
#include <foreach>
#include <izcmd>
#include <sscanf2>
#include <streamer>

#define _H "localhost"
#define _U "root"
#define _P ""
#define _D "uwuing"

//#define TAG_DISTANCE (200.00)
#define MAX_SPRAY (500) //5 * 100 players = 500
#define MAX_PLAYER_SPRAY (5) 

#define Message SendClientMessage
#define try%0(%1) forward%0(%1); public%0(%1)
//#define cache_get_data(%0,%1) cache_get_row_count(%0); cache_get_field_count(%0);
#define Prepare mysql_format

#define TAG_MAIN (1)
#define TAG_DELETE (2)
#define TAG_CREATE (3)
#define TAG_EDIT (4)
#define TAG_SELECTION (5)

#pragma tabsize 0

enum sprayData {
	sprayID,
	sprayExists, 
	sprayText[32],
	sprayOwner[MAX_PLAYER_NAME],
	sprayColor,
	sprayFontN[24],
	sprayFontS,
	sprayFontB,
	sprayObject,
	Float:sprayPosX,
	Float:sprayPosY,
	Float:sprayPosZ,
	Float:sprayRot
};

enum FixEnum {
	holdingID
};

new SprayData[MAX_SPRAY][sprayData];
new OnHandlingSpray[MAX_PLAYERS][sprayData];
new EditMode[MAX_PLAYERS][FixEnum];

new MySQL:DataBinding;

#if !defined FILTERSCRIPT
	main() {
		print("copyright 2019 by 0x1E4");
	}

	public OnPlayerSpawn(playerid)
	{
		SetPlayerInterior(playerid,0);
		TogglePlayerClock(playerid,0);
		return 1;
	}

	public OnPlayerDeath(playerid, killerid, reason)
	{
		ResetPreview(playerid);
		return 1;
	}

	SetupPlayerForClassSelection(playerid)
	{
		SetPlayerInterior(playerid,14);
		SetPlayerPos(playerid,258.4893,-41.4008,1002.0234);
		SetPlayerFacingAngle(playerid, 270.0);
		SetPlayerCameraPos(playerid,256.0815,-43.0475,1004.0234);
		SetPlayerCameraLookAt(playerid,258.4893,-41.4008,1002.0234);
		Streamer_Update(playerid);
	}

	public OnPlayerRequestClass(playerid, classid)
	{
		SetupPlayerForClassSelection(playerid);
		return 1;
	}

	public OnGameModeInit()
	{
		SetGameModeText("Your mom 2.0");
		ShowPlayerMarkers(1);
		ShowNameTags(1);
		AllowAdminTeleport(1);

		Loading();
		mysql_log(ERROR | WARNING);

		AddPlayerClass(265,1958.3783,1343.1572,15.3746,270.1425,0,0,0,0,-1,-1);

		return 1;
	}
	public OnGameModeExit()
	{
		foreach(new playerid : Player)
		{
			if(IsPlayerConnected(playerid))
				ResetPreview(playerid);
		}
		print("See you soon ^_^");
		mysql_close(DataBinding);
		return 1;
	}
#else 
	public OnFilterScriptInit()
	{
		Loading();	
		print("copyright 2019 by 0x1E4");
		return 1;
	}

	public OnFilterScriptExit()
	{
		foreach(new playerid : Player)
		{
			if(IsPlayerConnected(playerid))
				ResetPreview(playerid);
		}
		print("See you soon ^_^");
		mysql_close(DataBinding);
		return 1;
	}

#endif

public OnPlayerConnect(playerid)
{
	ResetPreview(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	ResetPreview(playerid);
	return 1;
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(response == EDIT_RESPONSE_FINAL)
	{
		SprayData[EditMode[playerid][holdingID]][sprayPosX] = x;
		SprayData[EditMode[playerid][holdingID]][sprayPosY] = y;
		SprayData[EditMode[playerid][holdingID]][sprayPosZ] = z;
		SprayData[EditMode[playerid][holdingID]][sprayRot] = rz;

		ReloadTags(EditMode[playerid][holdingID]);
		SaveTags(EditMode[playerid][holdingID]);

		Streamer_Update(playerid);
	}
	if (response == EDIT_RESPONSE_FINAL || response == EDIT_RESPONSE_CANCEL)
	{
		if(EditMode[playerid][holdingID] != -1) {
			ReloadTags(EditMode[playerid][holdingID]);
			Streamer_Update(playerid);
		}

		EditMode[playerid][holdingID] = -1;
	}
	return 1;
}
try Loading()
{
	new MySQLOpt: SQLConfiguration = mysql_init_options();
	mysql_set_option(SQLConfiguration, AUTO_RECONNECT, true);

	print(".........................");
	print("initializing MySQL Server");
	print(".........................");

	DataBinding = mysql_connect(_H, _U, _P, _D, SQLConfiguration);
	if (DataBinding == MYSQL_INVALID_HANDLE || mysql_errno(DataBinding) != 0)
	{
		print("Connection to host failed.");
		print("Note: maybe you missed the configuration or what?.");
		print(".........................");

		#if !defined FILTERSCRIPT
			SetTimer("Shutdown", 1500, false);
		#endif

		return 1;
	}
	print("Connection to host success.");
	print("You may proceed running this script");
	print(".........................");

	Build_Table();

	print("   Loading Process...    ");
	print(".........................");
	print("\n\n");
	print("Spraytag Status:");
	mysql_tquery(DataBinding, "SELECT * FROM `spraytags`", "LoadTags");
	return 1;
}

try Shutdown()
{
	mysql_close(DataBinding);
	SendRconCommand("exit");
	return 1;
}

try LoadTags()
{
	new rows, counat;
	cache_get_row_count(rows);

	for (new i = 0; i < rows; i ++) if (i < MAX_SPRAY)
	{
		SprayData[i][sprayExists] = true;
		cache_get_value_name_int(i, "sID", SprayData[i][sprayID]);

		cache_get_value_name(i, "sText", SprayData[i][sprayText], 32);
		cache_get_value_name(i, "sOwner", SprayData[i][sprayOwner], MAX_PLAYER_NAME);
		cache_get_value_name(i, "sFontName", SprayData[i][sprayFontN], 24);

		cache_get_value_name_int(i, "sColor", SprayData[i][sprayColor]);
		cache_get_value_name_int(i, "sFontSize", SprayData[i][sprayFontS]);
		cache_get_value_name_int(i, "sFontBold", SprayData[i][sprayFontB]);

		cache_get_value_name_float(i, "sPosX", SprayData[i][sprayPosX]);
		cache_get_value_name_float(i, "sPosY", SprayData[i][sprayPosY]);
		cache_get_value_name_float(i, "sPosZ", SprayData[i][sprayPosZ]);
		cache_get_value_name_float(i, "sRot", SprayData[i][sprayRot]);
		#if defined USE_DEBUG_LINE
			printf("[Debug Line] LoadTags() {\n   SprayID:%d\n   \
				SprayText:%s\n   \
				SprayOwner:%s\n   \
				SprayFontN:%s\n   \
				SprayColor:%d\n   \
				SprayFontSize:%d\n   \
				SprayFontBold:%d\n   \
				SprayPosX:%f\n   \
				SprayPosY:%f\n   \
				SprayPosZ:%f\n   \
				SprayRot:%f\n    \
			}",
			SprayData[i][sprayID], 
			SprayData[i][sprayText],
			SprayData[i][sprayOwner],
			SprayData[i][sprayFontN],
			SprayData[i][sprayColor],
			SprayData[i][sprayFontS],
			SprayData[i][sprayFontB],
			SprayData[i][sprayPosX],
			SprayData[i][sprayPosY],
			SprayData[i][sprayPosZ],
			SprayData[i][sprayRot]);
		#endif
		counat++;
		ReloadTags(i);
	}
	printf("%d/%d spray tag has been loaded successfully!", counat, MAX_SPRAY);
	print(".........................");
	return 1;
}

try ReloadTags(e)
{
	if(e != -1 && SprayData[e][sprayExists])
	{
		if (IsValidDynamicObject(SprayData[e][sprayObject]))
			DestroyDynamicObject(SprayData[e][sprayObject]);
	
		SprayData[e][sprayObject] = CreateDynamicObject(19353, SprayData[e][sprayPosX], SprayData[e][sprayPosY], SprayData[e][sprayPosZ], 0.0, 0.0, SprayData[e][sprayRot]);

		SetDynamicObjectMaterial(SprayData[e][sprayObject], 0, 0, "none", "none", 0);
		SetDynamicObjectMaterialText(SprayData[e][sprayObject], 0, SprayData[e][sprayText], OBJECT_MATERIAL_SIZE_512x512, SprayData[e][sprayFontN], SprayData[e][sprayFontS], SprayData[e][sprayFontB], SprayData[e][sprayColor], 0, 1);
	}

	return 1;
}

try InsertTagID(e)
{
	if (e == -1 || !SprayData[e][sprayExists])
		return 0;

	SprayData[e][sprayID] = cache_insert_id();
	SaveTags(e);
	return 1;
}

try DeleteTags(e)
{
	new query[128];

	if (IsValidDynamicObject(SprayData[e][sprayObject]))
		DestroyDynamicObject(SprayData[e][sprayObject]);
	
	Prepare(DataBinding, query, sizeof(query), "DELETE FROM `spraytags` WHERE `sID` = '%d'", SprayData[e][sprayID]);
	
	SprayData[e][sprayExists] = false;
	SprayData[e][sprayID] = -1;

	format(SprayData[e][sprayText], 32, "Exemplo");
	format(SprayData[e][sprayOwner], 24, "null");
	format(SprayData[e][sprayFontN], 24, "null");

	SprayData[e][sprayFontS] = -1;
	SprayData[e][sprayFontB] = -1;
	SprayData[e][sprayColor] = -1;

	SprayData[e][sprayPosX] = 0.0;
	SprayData[e][sprayPosY] = 0.0;
	SprayData[e][sprayPosZ] = 0.0;
	SprayData[e][sprayRot] = 0.0;

	mysql_query(DataBinding, query);
	return 1;
}

try ResetPreview(playerid)
{
	OnHandlingSpray[playerid][sprayID] = -1;

	format(OnHandlingSpray[playerid][sprayText], 32, "Exemplo");
	format(OnHandlingSpray[playerid][sprayOwner], 24, "null");
	format(OnHandlingSpray[playerid][sprayFontN], 24, "null");

	OnHandlingSpray[playerid][sprayFontS] = -1;
	OnHandlingSpray[playerid][sprayFontB] = -1;
	OnHandlingSpray[playerid][sprayColor] = -1;

	OnHandlingSpray[playerid][sprayPosX] = 0.0;
	OnHandlingSpray[playerid][sprayPosY] = 0.0;
	OnHandlingSpray[playerid][sprayPosZ] = 0.0;
	OnHandlingSpray[playerid][sprayRot] = 0.0;

	DeletePVar(playerid, "idx_1");
	DeletePVar(playerid, "idx_2");
	DeletePVar(playerid, "idx_3");
	DeletePVar(playerid, "idx_4");
	DeletePVar(playerid, "idx_5");
	DeletePVar(playerid, "TagSelection");
	DeletePVar(playerid, "CurrentSelect");
	DeletePVar(playerid, "FreeSlot");
	DeletePVar(playerid, "MaxSlot");
		

	DeletePVar(playerid, "selected_menu");
	DeletePVar(playerid, "edit_menu");


	return 1;
}

try OnPreviewCheck(playerid)
{
	if (!strcmp(OnHandlingSpray[playerid][sprayText], "Exemplo", true))
	{
		Message(playerid, 0xFFFFFFAA, "Please fill the font name");
		Open_Dialog(playerid, TAG_CREATE);
	}
	else if (OnHandlingSpray[playerid][sprayFontS] == 0)
	{
		Message(playerid, 0xFFFFFFAA, "Please fill the text size");
		Open_Dialog(playerid, TAG_CREATE);
	}
	else
	{
		new idx, outs[64];
		new Float:px, Float:py, Float:pz, Float:pang;

		GetPlayerPos(playerid, px, py, pz);
		GetPlayerFacingAngle(playerid, pang);

		idx = CreateTags(playerid, px-1.0, py, pz, pang);
		
		if(idx == -1)
			return Message(playerid, 0xFFFFFFAA, "Sorry, seems like the server has reached maximum of spray!");

		EditMode[playerid][holdingID] = idx;
		EditDynamicObject(playerid, SprayData[idx][sprayObject]);

		format(outs, sizeof(outs), "Successfully created spray tag with ID: %d", idx);
		Message(playerid, 0xFFFFFFAA, outs);
	}
	return 1;
}

Build_Table()
{
	new query[628];
	Prepare(DataBinding, query, sizeof(query),
		"CREATE TABLE IF NOT EXISTS `spraytags` ( \
			`sID` INT(12) NOT NULL AUTO_INCREMENT, \
			`sText` VARCHAR(32) DEFAULT 'Exemplo', \
			`sOwner` VARCHAR(25) DEFAULT NULL, \
			`sColor` VARCHAR(24) DEFAULT '-1', \
			`sFontName` VARCHAR(24) DEFAULT 'Arial', \
			`sFontSize` INT(12) DEFAULT '24', \
			`sFontBold` INT(12) DEFAULT '0', \
			`sPosX` FLOAT DEFAULT NULL, \
			`sPosY` FLOAT DEFAULT NULL, \
			`sPosZ` FLOAT DEFAULT NULL, \
			`sRot` FLOAT DEFAULT NULL, \
			PRIMARY KEY(`sID`) \
		)"
	);
	return mysql_tquery(DataBinding, query);
}

Open_Dialog(playerid, menu, tagid = -1)
{
	switch (menu)
	{
		case TAG_MAIN: Dialog_Show(playerid, TagsMain, DIALOG_STYLE_LIST, "Spraytag Editor - Menu", "Create Tags\nEdit Tags\nDelete Tags", "Select", "Close");
		case TAG_DELETE: Dialog_Show(playerid, TagsDelete, DIALOG_STYLE_MSGBOX, "Spraytag Editor - Confirm Delete", "Are you sure want to delete this?\n(This action cannot be undone!)", "Yes", "No");
		case TAG_CREATE:
		{
			new formattedtext[428];
			format(formattedtext, sizeof(formattedtext), 
					"Name\tPreview\n \
					Text\t%s\n \
					Color\t%s\n \
					Font Name\t%s\n \
					Font Size\t%d px\n \
					Font Bold\t%s\n \
					Create Tag",
				OnHandlingSpray[playerid][sprayText],
				SelectedColor(OnHandlingSpray[playerid][sprayColor]),
				OnHandlingSpray[playerid][sprayFontN],
				OnHandlingSpray[playerid][sprayFontS],
				(!OnHandlingSpray[playerid][sprayFontB]) ? ("No") : ("Yes")
			);
			Dialog_Show(playerid, TagCreateMenu, DIALOG_STYLE_TABLIST_HEADERS, "Spraytag Editor - Crate Tag Menu", formattedtext, "Select", "Back");
		}
		case TAG_EDIT:
		{
			new formattedtext[428];
			format(formattedtext, sizeof(formattedtext), 
					"Name\tPreview\n \
					Text\t%s\n \
					Color\t%s\n \
					Font Name\t%s\n \
					Font Size\t%d px\n \
					Font Bold\t%s\n",
				SprayData[tagid][sprayText],
				SelectedColor(SprayData[tagid][sprayColor]),
				SprayData[tagid][sprayFontN],
				SprayData[tagid][sprayFontS],
				(!SprayData[tagid][sprayFontB]) ? ("No") : ("Yes")
			);
			Dialog_Show(playerid, TagEditMenu, DIALOG_STYLE_TABLIST_HEADERS, "Spraytag Editor - Edit Tag Menu", formattedtext, "Select", "Back");
		}
		case TAG_SELECTION:
		{
			new output[320],named[MAX_PLAYER_NAME], couz;
			GetPlayerName(playerid, named, sizeof(named));

			for (new rx; rx < MAX_SPRAY; rx++) if (SprayData[rx][sprayExists] && !strcmp(SprayData[rx][sprayOwner], named, true))
			{
				new cache_output[12];
				format(output, sizeof(output), "%s %s%s\n", output, SelectedColor(SprayData[rx][sprayColor], 1), SprayData[rx][sprayText]);
				format(cache_output, sizeof(cache_output), "idx_%d", couz);
				SetPVarInt(playerid, cache_output, rx);
				couz++;
			}

			if (couz < MAX_PLAYER_SPRAY && (GetPVarInt(playerid, "TagSelection") == 1))
			{
				format(output, sizeof(output), "%s Create tag here!", output);
				SetPVarInt(playerid, "FreeSlot", couz);
			}
			else if(couz == MAX_PLAYER_SPRAY)
				SetPVarInt(playerid, "MaxSlot", 1);

			Dialog_Show(playerid, TagsSelection, DIALOG_STYLE_LIST, "Spraytag Edit - Tag Selection menu", output, "Select", "Back");
		}
	}
	return 1;
}

SelectedColor(colorhex, formatable = 0)
{
	new rase[64];
	if(formatable)
	{
		switch(colorhex)
		{
			case -1: rase = "{FFFFFF}";
			case -65536: rase = "{FF0000}";
			case -256: rase = "{FFFF00}";
			case -13382605: rase = "{33CC33}";
			case -13382401: rase = "{33CCFF}";
			case -23296: rase = "{FFA500}";
			case -1549353: rase = "{1394BF}";
		}
	}
	else 
	{
		switch(colorhex)
		{
			case -1: rase = "{FFFFFF}White";
			case -65536: rase = "{FF0000}Red";
			case -256: rase = "{FFFF00}Yellow";
			case -13382605: rase = "{33CC33}Green";
			case -13382401: rase = "{33CCFF}Light Blue";
			case -23296: rase = "{FFA500}Orange";
			case -1549353: rase = "{1394BF}Dark Blue";
		}
	}
	return rase;
}

CreateTags(playerid, Float:ox, Float:oy, Float:oz, Float:oang)
{
	new query[64];
	for (new e; e != MAX_SPRAY; e++) if (!SprayData[e][sprayExists])
	{
		SprayData[e][sprayExists] = true;

		format(SprayData[e][sprayText], 32, OnHandlingSpray[playerid][sprayText]);
		format(SprayData[e][sprayOwner], 24, GetName(playerid));
		format(SprayData[e][sprayFontN], 24, OnHandlingSpray[playerid][sprayFontN]);

		SprayData[e][sprayFontS] = OnHandlingSpray[playerid][sprayFontS];
		SprayData[e][sprayFontB] = OnHandlingSpray[playerid][sprayFontB];
		SprayData[e][sprayColor] = OnHandlingSpray[playerid][sprayColor];

		SprayData[e][sprayPosX] = ox;
		SprayData[e][sprayPosY] = oy;
		SprayData[e][sprayPosZ] = oz;
		SprayData[e][sprayRot] = oang - 90.0;

		ResetPreview(playerid);
		ReloadTags(e);

		format(query, sizeof(query), "INSERT INTO `spraytags` (`sOwner`) VALUES ('%s')", GetName(playerid));
		mysql_tquery(DataBinding, query, "InsertTagID", "d", e);
		return e;
	}
	ResetPreview(playerid);
	return -1;
}

SaveTags(e)
{
	new query[2048];
	format(query, sizeof(query), "UPDATE `spraytags` SET `sText` = '%s', `sOwner` = '%s', `sColor` = '%d', `sFontName` = '%s', `sFontSize` = '%d', `sFontBold` = '%d', `sPosX` =  '%.4f', `sPosY` =  '%.4f', `sPosZ` =  '%.4f', `sRot` =  '%.4f' WHERE `sID` = '%d'",
		SprayData[e][sprayText],
		SprayData[e][sprayOwner], 
		SprayData[e][sprayColor],
		SprayData[e][sprayFontN],
		SprayData[e][sprayFontS],
		SprayData[e][sprayFontB],
		SprayData[e][sprayPosX],
		SprayData[e][sprayPosY],
		SprayData[e][sprayPosZ],
		SprayData[e][sprayRot],
		SprayData[e][sprayID]
	);
	return mysql_tquery(DataBinding, query);
}

GetName(playerid)
{
	new user[MAX_PLAYER_NAME];
	GetPlayerName(playerid, user, sizeof(user));
	return user;
}

IsNumeric(const str[])
{
	for (new i = 0, l = strlen(str); i != l; i ++)
	{
	    if (i == 0 && str[0] == '-')
			continue;

	    else if (str[i] < '0' || str[i] > '9')
			return 0;
	}
	return 1;
}

//dialog
Dialog:TagsMain(playerid, response, listitem, inputtext[])
{
	if (!response) return 0;

	switch (listitem)
	{
		case 0:
		{
			SetPVarInt(playerid, "TagSelection", 1);
			Open_Dialog(playerid, TAG_SELECTION);
		}
		case 1:
		{
			SetPVarInt(playerid, "TagSelection", 2);
			Open_Dialog(playerid, TAG_SELECTION);
		}
		case 2:
		{
			SetPVarInt(playerid, "TagSelection", 3);
			Open_Dialog(playerid, TAG_SELECTION);
		}
	}
	return 1;
}

Dialog:TagsSelection(playerid, response, listitem, inputtext[])
{
	new pvarz[12];
	if (!response) 
	{
		ResetPreview(playerid);
		return Open_Dialog(playerid, TAG_MAIN);
	}

	if (!GetPVarInt(playerid, "CurrentSelect"))
	{
		format(pvarz, sizeof(pvarz), "idx_%d", listitem);
		SetPVarInt(playerid, "CurrentSelect", GetPVarInt(playerid, pvarz));
		DeletePVar(playerid, pvarz);
	}

	switch (GetPVarInt(playerid, "TagSelection"))
	{
		case 1: 
		{
			if((GetPVarInt(playerid, "FreeSlot") != listitem) && listitem == 0)
				return Dialog_Show(playerid, AlertPlayer, DIALOG_STYLE_MSGBOX, "Warning!", "You cannot create tag on that slot!", "Back", "");
			else if(GetPVarInt(playerid, "FreeSlot") != listitem || GetPVarInt(playerid, "MaxSlot"))
				return Dialog_Show(playerid, AlertPlayer, DIALOG_STYLE_MSGBOX, "Warning!", "You cannot create tag on that slot!", "Back", "");
			Open_Dialog(playerid, TAG_CREATE);	
		}
		case 2: Open_Dialog(playerid, TAG_EDIT, GetPVarInt(playerid, "CurrentSelect"));
		case 3: Open_Dialog(playerid, TAG_DELETE);
	}
	return 1;
}

Dialog:TagsDelete(playerid, response, listitem, inputtext[])
{
	if (!response) 
		return Open_Dialog(playerid, TAG_MAIN);
	
	DeleteTags(GetPVarInt(playerid, "CurrentSelect"));
	DeletePVar(playerid, "CurrentSelect");

	Open_Dialog(playerid, TAG_MAIN);
	return 1;
}

Dialog:AlertPlayer(playerid, response, listitem, inputtext[])
	return Open_Dialog(playerid, TAG_SELECTION);

Dialog:TagCreateMenu(playerid, response, listitem, inputtext[])
{
	if (!response) 
	{
		SetPVarInt(playerid, "selected_menu", -1);
		Open_Dialog(playerid, TAG_MAIN);
		return 1;
	}

	SetPVarInt(playerid, "selected_menu", listitem);
	switch (listitem)
	{
		case 0: Dialog_Show(playerid, OnCreateResponz, DIALOG_STYLE_INPUT, "Edit Spray Text", "Please type below on box\nto change the new text", "Done", "Back");
		case 1: Dialog_Show(playerid, OnCreateResponz, DIALOG_STYLE_LIST, "Edit Spray Color", "{FFFFFF}White\n{FF0000}Red\n{FFFF00}Yellow\n{33CC33}Green\n{33CCFF}Light Blue\n{FFA500}Orange\n{1394BF}Dark Blue", "Done", "Back");
		case 2: Dialog_Show(playerid, OnCreateResponz, DIALOG_STYLE_LIST, "Edit Spray Font Name", "Arial\nBarrio Santo\nCaveman\nGraffitasi\nMost Wazted\nSugar Death 2", "Done", "Back");
		case 3: Dialog_Show(playerid, OnCreateResponz, DIALOG_STYLE_INPUT, "Edit Spray Text Size", "Please type the size below on box\nto change the new text size", "Done", "Back");
		case 4: Dialog_Show(playerid, OnCreateResponz, DIALOG_STYLE_MSGBOX, "Edit Font Bold", "Please click below on box\nto change the new text bold", "Bold", "Normal");
		case 5: OnPreviewCheck(playerid);
	}
	return 1;
}

Dialog:TagEditMenu(playerid, response, listitem, inputtext[])
{
	if (!response) 
	{
		SetPVarInt(playerid, "edit_menu", -1);
		Open_Dialog(playerid, TAG_MAIN);
		return 1;
	}

	SetPVarInt(playerid, "edit_menu", listitem);
	switch (listitem)
	{
		case 0: Dialog_Show(playerid, OnEditResponz, DIALOG_STYLE_INPUT, "Edit Spray Text", "Please type below on box\nto change the new text", "Done", "Back");
		case 1: Dialog_Show(playerid, OnEditResponz, DIALOG_STYLE_LIST, "Edit Spray Color", "{FFFFFF}White\n{FF0000}Red\n{FFFF00}Yellow\n{33CC33}Green\n{33CCFF}Light Blue\n{FFA500}Orange\n{1394BF}Dark Blue", "Done", "Back");
		case 2: Dialog_Show(playerid, OnEditResponz, DIALOG_STYLE_LIST, "Edit Spray Font Name", "Arial\nBarrio Santo\nCaveman\nGraffitasi\nMost Wazted\nSugar Death 2", "Done", "Back");
		case 3: Dialog_Show(playerid, OnEditResponz, DIALOG_STYLE_INPUT, "Edit Spray Text Size", "Please type the size below on box\nto change the new text size", "Done", "Back");
		case 4: Dialog_Show(playerid, OnEditResponz, DIALOG_STYLE_MSGBOX, "Edit Font Bold", "Please click below on box\nto change the new text bold", "Bold", "Normal");
	}
	return 1;
}

Dialog:OnCreateResponz(playerid, response, listitem, inputtext[])
{
	if (!response) return Open_Dialog(playerid, TAG_CREATE);

	switch (GetPVarInt(playerid, "selected_menu"))
	{
		case 0: 
		{
			format(OnHandlingSpray[playerid][sprayText], 32, inputtext);
			Message(playerid, 0xFFFFFFAA, "Successfully edited spray text!");
			Open_Dialog(playerid, TAG_CREATE);
		}
		case 1: 
		{
			
			switch (listitem)
			{
				case 0:
					OnHandlingSpray[playerid][sprayColor] = 0xFFFFFFFF;

				case 1:
					OnHandlingSpray[playerid][sprayColor] = 0xFFFF0000;

				case 2:
					OnHandlingSpray[playerid][sprayColor] = 0xFFFFFF00;

				case 3:
					OnHandlingSpray[playerid][sprayColor] = 0xFF33CC33;

				case 4:
					OnHandlingSpray[playerid][sprayColor] = 0xFF33CCFF;

				case 5:
					OnHandlingSpray[playerid][sprayColor] = 0xFFFFA500;

				case 6:
					OnHandlingSpray[playerid][sprayColor] = 0xFF1394BF;
			}
			Message(playerid, 0xFFFFFFAA, "Successfully edited spray color!");
			Open_Dialog(playerid, TAG_CREATE);
		}
		case 2: 
		{
			format(OnHandlingSpray[playerid][sprayFontN], 32, inputtext);
			Message(playerid, 0xFFFFFFAA, "Successfully edited spray font!");
			Open_Dialog(playerid, TAG_CREATE);
		}
		case 3: 
		{
			if (!IsNumeric(inputtext)) 
				return Dialog_Show(playerid, OnCreateResponz, DIALOG_STYLE_INPUT, "Edit Spray Text Size", "Please type the size below on box\nto change the new text size", "Done", "Back"); 
			
			OnHandlingSpray[playerid][sprayFontS] = strval(inputtext);
			Message(playerid, 0xFFFFFFAA, "Successfully edited spray text size!");
			Open_Dialog(playerid, TAG_CREATE);
		}
		case 4:
		{
			if(OnHandlingSpray[playerid][sprayFontB])
			{
				OnHandlingSpray[playerid][sprayFontB] = 0;
				Open_Dialog(playerid, TAG_CREATE);
			}
			else
			{
				OnHandlingSpray[playerid][sprayFontB] = 1;
				Open_Dialog(playerid, TAG_CREATE);
			}
		}
	}
	SetPVarInt(playerid, "selected_menu", -1);
	return 1;
}

Dialog:OnEditResponz(playerid, response, listitem, inputtext[])
{
	if (!response && listitem != 4) return Open_Dialog(playerid, TAG_EDIT, GetPVarInt(playerid, "CurrentSelect"));

	new sprayid = GetPVarInt(playerid, "CurrentSelect");
	switch (GetPVarInt(playerid, "edit_menu"))
	{
		case 0: 
		{
			format(SprayData[sprayid][sprayText], 32, inputtext);
			Message(playerid, 0xFFFFFFAA, "Successfully edited spray text!");

			ReloadTags(sprayid);
			Streamer_Update(playerid);

			SaveTags(sprayid);
			Open_Dialog(playerid, TAG_EDIT, sprayid);
		}
		case 1: 
		{
			switch (listitem)
			{
				case 0:
					SprayData[sprayid][sprayColor] = 0xFFFFFFFF;

				case 1:
					SprayData[sprayid][sprayColor] = 0xFFFF0000;

				case 2:
					SprayData[sprayid][sprayColor] = 0xFFFFFF00;

				case 3:
					SprayData[sprayid][sprayColor] = 0xFF33CC33;

				case 4:
					SprayData[sprayid][sprayColor] = 0xFF33CCFF;

				case 5:
					SprayData[sprayid][sprayColor] = 0xFFFFA500;

				case 6:
					SprayData[sprayid][sprayColor] = 0xFF1394BF;
			}
			Message(playerid, 0xFFFFFFAA, "Successfully edited spray color!");

			ReloadTags(sprayid);
			Streamer_Update(playerid);

			SaveTags(sprayid);
			Open_Dialog(playerid, TAG_EDIT, sprayid);
		}
		case 2: 
		{
			format(SprayData[sprayid][sprayFontN], 32, inputtext);
			Message(playerid, 0xFFFFFFAA, "Successfully edited spray font!");

			ReloadTags(sprayid);
			Streamer_Update(playerid);

			SaveTags(sprayid);
			Open_Dialog(playerid, TAG_EDIT, sprayid);
		}
		case 3: 
		{
			if (!IsNumeric(inputtext)) return Dialog_Show(playerid, OnEditResponz, DIALOG_STYLE_INPUT, "Edit Spray Text Size", "Please type the size below on box\nto change the new text size", "Done", "Back"); 
			
			SprayData[sprayid][sprayFontS] = strval(inputtext);
			Message(playerid, 0xFFFFFFAA, "Successfully edited spray text size!");

			ReloadTags(sprayid);
			Streamer_Update(playerid);

			SaveTags(sprayid);
			Open_Dialog(playerid, TAG_EDIT, sprayid);
		}
		case 4:
		{
			if(SprayData[sprayid][sprayFontB])
			{
				SprayData[sprayid][sprayFontB] = 0;

				ReloadTags(sprayid);
				Streamer_Update(playerid);

				SaveTags(sprayid);
				Open_Dialog(playerid, TAG_EDIT, sprayid);
			}
			else 
			{
				SprayData[sprayid][sprayFontB] = 1;

				ReloadTags(sprayid);
				Streamer_Update(playerid);

				SaveTags(sprayid);
				Open_Dialog(playerid, TAG_EDIT, sprayid);
			}
		}
	}
	SetPVarInt(playerid, "edit_menu", -1);
	return 1;
}

CMD:tags(playerid, syntax[])
{
	#pragma unused syntax
	Open_Dialog(playerid, TAG_MAIN);
	return 1;
}

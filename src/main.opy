#!setupTags

rule "6.1: Initialize Match":
    disableAnnouncer()
    disableGamemodeCompletion()
    setMatchTime(0)
    if not settings_[0]:
        disableInspector()
    if settings_[1]:
        players = []
        #Global.lobbyStats[i]: [0]players [1]rejoins [2]legitRuns [3]totalRunTime [4]totalRunTimeFormatted [5]totalMistakes [6]avgRunTime [7]avgRunTimeFormatted [8]avgMistakes
        lobbyStats = []
        lobbyStats[0] = 0
        lobbyStats[1] = 0
        lobbyStats[2] = 0
        lobbyStats[3] = 0
        lobbyStats[4] = "00:00.00"
        lobbyStats[5] = 0
        lobbyStats[6] = 0
        lobbyStats[7] = "00:00.00"
        lobbyStats[8] = 0
    playersUnpaused = 0

rule "6.2: Start Elapsed Timer":
    chaseAtRate(elapsedTime, 14340, 1)
    if settings_[1] and not settings_[0]:
        elapsedTimeFormatted = (
            "{}:{}:{}".format(
                floor(elapsedTime / 3600),
                (elapsedTime % 3600 / 60 + 100).substring(1, 2),
                (elapsedTime % 60 + 100).substring(1, 9999)
            ) if elapsedTime >= 3600 else
            "{}:{}".format(
                floor(elapsedTime / 60),
                (elapsedTime % 60 + 100).substring(1, 9999)
            ) if elapsedTime >= 60 else
            "{}.{}".format(
                floor(elapsedTime),
                (round(elapsedTime % 1 * 100) + 100).substring(1, 2)
            )
        )
        wait(0.1)
        loop()

rule "7.1: Player Joins":
    @Event playerJoined
    @Condition eventPlayer.isDummy() == false
    
    eventPlayer.isLoading = true
    if not "{}".format(eventPlayer) in players:
        if eventPlayer == hostPlayer:
            hostPlayerName = "{}".format(eventPlayer)
        lobbyStats[0]++
        players[len(players)] = "{}".format(eventPlayer)
    else:
        lobbyStats[1]++
    waitUntil(eventPlayer.hasSpawned(), 99999999)
    eventPlayer.disableGamemodeHud()
    eventPlayer.disableKillFeed()
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disableNameplatesFor(getAllPlayers())
    getAllPlayers().disableNameplatesFor(eventPlayer)
    eventPlayer.disablePlayerCollision()
    wait()
    loadLobby()
    wait(0.1)
    eventPlayer.isLoading = false


rule "7.2: Player Leaves":
    @Event playerLeft
    @Condition eventPlayer.isDummy() == false
    
    if not eventPlayer.isRunPaused:
        playersUnpaused--
    destroyInWorldText(eventPlayer.nameplateObject)
    unloadCpObjects()
    unloadHud()
    unloadFreemodeHud()
    unloadRunCompletionText()
    destroyHudText(eventPlayer.ctrlsHud)


def loadNameplate():
    @Name "8: Load Nameplate"
    
    if eventPlayer.isInLobby:
        eventPlayer.nameplate = "{}".format(eventPlayer)
    else:
        if not eventPlayer.isInFreemode:
            eventPlayer.nameplate = "{} | {}".format("{}".format(eventPlayer), eventPlayer.runCurrentCp)
        else:
            eventPlayer.nameplate = "{} | FREEMODE".format("{}".format(eventPlayer))
    createInWorldText(getAllPlayers().filter(lambda player: player != eventPlayer), eventPlayer.nameplate, eventPlayer, 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING)
    eventPlayer.nameplateObject = getLastCreatedText()


def loadLobby():
    @Name "9.1: Load Lobby"
    
    eventPlayer.teleport(lobbyData[0])
    eventPlayer.isInLobby = true
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), lobbyData[1]), Relativity.TO_WORLD)
    eventPlayer.isInFreemode = false
    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.allowButton(Button.CROUCH)
    destroyInWorldText(eventPlayer.nameplateObject)
    loadNameplate()


rule "9.2: Load Welcome Area":
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby), "Welcome to", lobbyData[2], lobbyData[4], Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby), "Ballkour!", lobbyData[3], lobbyData[4], Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ORANGE)


rule "9.3: Load Leaderboard Area":
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby), "Leaderboard", lobbyData[11], lobbyData[12], Clip.SURFACES, WorldTextReeval.VISIBILITY, rgb(165, 42, 42))
    for index in range(1, 11):
        if lb[index] != null:
            formatLbString()
            createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby), lbObjFormatted, lbPos[index], lobbyData[13], Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE)
        else:
            if lb[index] <= 9:
                createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby), "<fgA52A2AFF>{}</fg>. <fgEC9900FF>---</fg>                                               <fgA52A2AFF>(</fg>{}<fgEC9900FF>-:--.--, {}-</fg><fgA52A2AFF>)</fg>".format(index, iconString(Icon.BOLT), iconString(Icon.SKULL)), lbPos[index], lobbyData[13], Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE)
            else:
                createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby), "<fgA52A2AFF>10</fg>. <fgEC9900FF>---</fg>                                              <fgA52A2AFF>(</fg>{}<fgEC9900FF>-:--.--, {}-</fg><fgA52A2AFF>)</fg>".format(iconString(Icon.BOLT), iconString(Icon.SKULL)), lbPos[index], lobbyData[13], Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE)


def formatLbString():
    @Name "9.3.1: Format Leaderboard String"
    
    #Global.lbObj[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator
    lbObj = lb[index].split(",")
    lbObj[3] = lbObj[3].replace("'", "")
    lbObjFormatted = "<fgA52A2AFF>{}</fg>. <fgEC9900FF>{}</fg>{}<fgA52A2AFF>(</fg>{}<fgEC9900FF>{}, {}{}</fg><fgA52A2AFF>)</fg>".format(index, lbObj[0], lbObj[3], iconString(Icon.BOLT), lbObj[1], iconString(Icon.SKULL), lbObj[2])


rule "9.4.1: Load Start Run Area":
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby), "New Run", lobbyData[7], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.TURQUOISE)
    createEffect(getAllPlayers().filter(lambda player: player.isInLobby), Effect.RING, Color.SKY_BLUE, lobbyData[5], 1.6, EffectReeval.VISIBILITY)
    createIcon(getAllPlayers().filter(lambda player: player.isInLobby), lobbyData[6], Icon.FLAG, IconReeval.VISIBILITY, Color.GREEN, false)
    createEffect(getAllPlayers().filter(lambda player: player.isInLobby), Effect.SPARKLES, Color.ORANGE, lobbyData[5] + vect(0, -0.85, 0), 1.6, EffectReeval.VISIBILITY)


rule "9.4.2: Start Run Circle Entry":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInLobby == true
    @Condition distance(eventPlayer.getPosition(), lobbyData[5]) <= 2
    
    eventPlayer.isInLobby = false
    eventPlayer.isLoading = true
    newRun()
    loadHud()
    destroyInWorldText(eventPlayer.nameplateObject)
    loadNameplate()
    eventPlayer.isLoading = false


rule "9.5.1: Load Resume Run Area":
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby and player.isRunLoaded and not player.isRunFinished), "Resume Run", lobbyData[10], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.TURQUOISE)
    createEffect(getAllPlayers().filter(lambda player: player.isInLobby and player.isRunLoaded and not player.isRunFinished), Effect.RING, Color.GREEN, lobbyData[8], 1.6, EffectReeval.VISIBILITY)
    createIcon(getAllPlayers().filter(lambda player: player.isInLobby and player.isRunLoaded and not player.isRunFinished), lobbyData[9], Icon.RECYCLE, IconReeval.VISIBILITY, Color.GREEN, false)
    createEffect(getAllPlayers().filter(lambda player: player.isInLobby and player.isRunLoaded and not player.isRunFinished), Effect.SPARKLES, Color.ORANGE, lobbyData[8] + vect(0, -0.85, 0), 1.6, EffectReeval.VISIBILITY)


rule "9.5.2: Resume Run Circle Entry":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInLobby == true
    @Condition eventPlayer.isRunLoaded == true
    @Condition eventPlayer.isRunFinished == false
    @Condition distance(eventPlayer.getPosition(), lobbyData[10]) <= 2
    
    eventPlayer.isInLobby = false
    eventPlayer.isLoading = true
    cpResetPlayer()
    setCpAbilities()
    loadCpObjects()
    loadHud()
    destroyInWorldText(eventPlayer.nameplateObject)
    loadNameplate()
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), cps[eventPlayer.runCurrentCp][6]), Relativity.TO_WORLD)
    eventPlayer.isLoading = false


rule "9.6: Load Lobby Stats":
    @Condition settings_[1] == true
    
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby and "{}".format(player) == hostPlayerName), "Stats", lobbyData[14], 1.2, Clip.SURFACES, WorldTextReeval.VISIBILITY, rgb(165, 42, 42))
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby and "{}".format(player) == hostPlayerName), "Elapsed Time: {}".format(elapsedTimeFormatted if not settings_[0] else elapsedTime), lobbyData[15], 0.85, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby and "{}".format(player) == hostPlayerName), "New Players: {}".format(lobbyStats[0]), lobbyData[16], 0.85, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby and "{}".format(player) == hostPlayerName), "Rejoins: {}".format(lobbyStats[1]), lobbyData[17], 0.85, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby and "{}".format(player) == hostPlayerName), "Legit Runs: {}".format(lobbyStats[2]), lobbyData[18], 0.85, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby and "{}".format(player) == hostPlayerName), "Total Run Time: {}".format(lobbyStats[4]), lobbyData[19], 0.85, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby and "{}".format(player) == hostPlayerName), "Total Mistakes: {}".format(lobbyStats[5]), lobbyData[20], 0.85, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby and "{}".format(player) == hostPlayerName), "Avg Run Time: {}".format(lobbyStats[7]), lobbyData[21], 0.85, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda player: player.isInLobby and "{}".format(player) == hostPlayerName), "Total Mistakes: {}".format(lobbyStats[8]), lobbyData[22], 0.85, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)


rule "10: Clear Unused Variables":
    lb = null
    lbPos = null
    lbObj = null
    lbObjFormatted = null


rule "11.1: Load Global Run HUD":
    hudSubtext(getAllPlayers(), "ballkour.com", HudPosition.TOP, 0, rgb(165, 42, 42), HudReeval.VISIBILITY)


def loadHud():
    @Name "11.2.1: Load Local Run HUD"
    
    eventPlayer.runHud = []
    hudSubtext(eventPlayer, "\n\n\n\nControls: {}".format(inputBindingString(Button.ULTIMATE)), HudPosition.LEFT, 0, Color.ORANGE, HudReeval.STRING)
    eventPlayer.runHud[0] = getLastCreatedText()
    hudSubtext(eventPlayer, "{}/{}".format(eventPlayer.runCurrentCp, len(cps) - 1), HudPosition.TOP, 1, Color.ORANGE, HudReeval.STRING)
    eventPlayer.runHud[1] = getLastCreatedText()
    if not settings_[0]:
        hudSubtext(eventPlayer, "\n\n\n\n{} {}\n".format(iconString(Icon.BOLT), eventPlayer.runTimeFormatted), HudPosition.RIGHT, 1, Color.ORANGE, HudReeval.STRING)
    else:
        hudSubtext(eventPlayer, "\n\n\n\n{} {}\n".format(iconString(Icon.BOLT), eventPlayer.runTime), HudPosition.RIGHT, 1, Color.ORANGE, HudReeval.STRING)
    eventPlayer.runHud[2] = getLastCreatedText()
    hudSubtext(eventPlayer, "{} {}".format(iconString(Icon.SKULL), eventPlayer.runMistakes), HudPosition.RIGHT, 3, Color.ORANGE, HudReeval.STRING)
    eventPlayer.runHud[3] = getLastCreatedText()


def unloadHud():
    @Name "11.2.2: Unload Local Run HUD"
    
    for eventPlayer.index in range(len(eventPlayer.runHud)):
        destroyHudText(eventPlayer.runHud[eventPlayer.index])


def newRun():
    @Name "12: Initialize New Run"
    
    eventPlayer.isRunLoaded = false
    eventPlayer.isRunLoaded = true
    eventPlayer.isRunPaused = true
    eventPlayer.isInFreemode = false
    eventPlayer.isRunFinished = false
    eventPlayer.isRunLegit = true
    eventPlayer.runCurrentCp = 0
    eventPlayer.runTime = 0
    eventPlayer.runTimeFormatted = "0.00"
    eventPlayer.runMistakes = 0
    loadCp()
    wait()
    cpResetPlayer()
    setCpAbilities()
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), cps[eventPlayer.runCurrentCp][6]), Relativity.TO_WORLD)


def loadCp():
    @Name "13.1: Load Checkpoint"
    
    unloadCpObjects()
    loadCpData()
    if eventPlayer.runCurrentCp < len(cps) - 1:
        loadCpObjects()
    setCpAbilities()


def loadCpData():
    @Name "13.2: Load Checkpoint Data"
    
    #Event Player.cpData[i]: [0]cpLocation [1]cpSize [2]grappleAllowed [3]piledriverAllowed [4]bounceLocation [5]bounceSize [6]nextCpLocation [7]nextCpSize [8]grappling [9]grappleUsed [10]jumping [11]jumped [12]bhopped [13]bounceUsed [14]piledriving [15]deathLocation
    eventPlayer.cpData = []
    eventPlayer.cpData[0] = cps[eventPlayer.runCurrentCp][0]
    if eventPlayer.runCurrentCp == len(cps) - 1:
        return
    eventPlayer.cpData[1] = cps[eventPlayer.runCurrentCp][1]
    eventPlayer.cpData[2] = cps[eventPlayer.runCurrentCp][2]
    eventPlayer.cpData[3] = cps[eventPlayer.runCurrentCp][3]
    eventPlayer.cpData[4] = cps[eventPlayer.runCurrentCp][4]
    eventPlayer.cpData[5] = cps[eventPlayer.runCurrentCp][5]
    eventPlayer.cpData[6] = cps[eventPlayer.runCurrentCp][6]
    eventPlayer.cpData[7] = cps[eventPlayer.runCurrentCp][7]
    eventPlayer.cpData[9] = false
    eventPlayer.cpData[11] = false
    eventPlayer.cpData[12] = false
    eventPlayer.cpData[13] = false
    eventPlayer.cpTime = 0


def loadCpObjects():
    @Name "13.3.1: Load Checkpoint Objects"
    
    #Event Player.cpEffects[i]: [0]cpRing [1]bounceCpRing [2]nextCpRing [3]nextCpRing
    eventPlayer.cpEffects = []
    #Event Player.cpIcons[i]: [0]bounceCpJumpIcon [1]nextCpFlag
    eventPlayer.cpIcons = []
    createEffect(eventPlayer, Effect.RING, Color.GREEN, eventPlayer.cpData[0], eventPlayer.cpData[1], EffectReeval.POSITION_AND_RADIUS)
    eventPlayer.cpEffects[0] = getLastCreatedEntity()
    if eventPlayer.cpData[4] != null:
        createEffect(eventPlayer, Effect.RING, Color.ORANGE, eventPlayer.cpData[4], eventPlayer.cpData[5], EffectReeval.POSITION_AND_RADIUS)
        eventPlayer.cpEffects[1] = getLastCreatedEntity()
        createIcon(eventPlayer, eventPlayer.cpData[4], Icon.ARROW_UP, IconReeval.POSITION, Color.YELLOW, false)
        eventPlayer.cpIcons[0] = getLastCreatedEntity()
    createEffect(eventPlayer, Effect.RING, Color.SKY_BLUE, eventPlayer.cpData[6], eventPlayer.cpData[7], EffectReeval.POSITION_AND_RADIUS)
    eventPlayer.cpEffects[2] = getLastCreatedEntity()
    createIcon(eventPlayer, eventPlayer.cpData[6] - vect(0, 0.5, 0), Icon.FLAG, IconReeval.POSITION, Color.GREEN)
    eventPlayer.cpIcons[1] = getLastCreatedEntity()
    createEffect(eventPlayer, Effect.LIGHT_SHAFT, rgb(72, 127, 163, 0), eventPlayer.cpData[6], eventPlayer.cpData[7], EffectReeval.POSITION_AND_RADIUS)
    eventPlayer.cpEffects[3] = getLastCreatedEntity()


def unloadCpObjects():
    @Name "13.3.2: Unload Checkpoint Objects"
    
    destroyEffect(eventPlayer.cpEffects[0])
    if eventPlayer.cpData[4] != null:
        destroyEffect(eventPlayer.cpEffects[1])
        destroyIcon(eventPlayer.cpIcons[0])
    destroyEffect(eventPlayer.cpEffects[2])
    destroyEffect(eventPlayer.cpEffects[3])
    destroyIcon(eventPlayer.cpIcons[1])


def setCpAbilities():
    @Name "13.4: Set Checkpoint Abilities"
    
    if eventPlayer.runCurrentCp < len(cps) - 1 and not eventPlayer.isInFreemode:
        eventPlayer.setSecondaryFireEnabled(eventPlayer.cpData[2])
        if not eventPlayer.cpData[3]:
            eventPlayer.disallowButton(Button.CROUCH)
        else:
            eventPlayer.allowButton(Button.CROUCH)
    else:
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.allowButton(Button.CROUCH)


rule "14.1: Start/Resume Run":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isRunPaused == true
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]
    
    eventPlayer.isRunPaused = false
    chaseAtRate(eventPlayer.runTime, 99999999, 1)


rule "14.2: Update Run Timer Format":
    @Event eachPlayer
    @Condition eventPlayer.isTimerActive == false
    @Condition eventPlayer.isRunPaused == false
    @Condition eventPlayer.isRunLoaded == true
    @Condition settings_[0] == false
    
    playersUnpaused++
    eventPlayer.isTimerActive = true
    while not eventPlayer.isRunPaused:
        if playersUnpaused >= 10:
            wait(0.096 + getServerLoad() * 0.0004)
        elif playersUnpaused >= 8:
            wait(0.08 + getServerLoad() * 0.0004)
        elif playersUnpaused >= 6:
            wait(0.064 + getServerLoad() * 0.0004)
        elif playersUnpaused >= 4:
            wait(0.048 + getServerLoad() * 0.0006)
        elif playersUnpaused >= 2:
            wait(0.032 + getServerLoad() * 0.0008)
        else:
            wait(0.016 + getServerLoad() * 0.001)
        eventPlayer.runTimeFormatted = (
            "{}:{}:{}".format(
                floor(eventPlayer.runTime / 3600),
                (eventPlayer.runTime % 3600 / 60 + 100).substring(1, 2),
                (eventPlayer.runTime % 60 + 100).substring(1, 9999)
            ) if eventPlayer.runTime >= 3600 else
            "{}:{}".format(
                floor(eventPlayer.runTime / 60),
                (eventPlayer.runTime % 60 + 100).substring(1, 9999)
            ) if eventPlayer.runTime >= 60 else
            "{}.{}".format(
                floor(eventPlayer.runTime),
                (round(eventPlayer.runTime % 1 * 100) + 100).substring(1, 2)
            )
        )
    playersUnpaused--
    eventPlayer.isTimerActive = false


rule "15: Start Checkpoint Time Timer":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]
    
    chaseAtRate(eventPlayer.cpTime, 99999999, 1)


rule "16.1: Grappling":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    
    if eventPlayer.isInLobby or eventPlayer.cpData[4] == null or eventPlayer.isInFreemode:
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    else:
        eventPlayer.cpData[8] = true
        waitUntil(not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or eventPlayer.getSpeed() > 5, 99999999)
        if eventPlayer.getSpeed() > 5:
            waitUntil(not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE), 8.5)
        eventPlayer.cpData[8] = false
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]:
            eventPlayer.cpData[9] = true
        else:
            eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)


rule "16.2.1: Jumping":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isJumping() == true
    
    eventPlayer.cpData[10] = true
    eventPlayer.cpData[11] = true
    waitUntil(eventPlayer.isOnGround(), 0.016)
    eventPlayer.cpData[10] = false


rule "16.2.2: Bhopping":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isInLobby == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[6]) >= eventPlayer.cpData[7]
    
    if not eventPlayer.cpData[12]:
        waitUntil(eventPlayer.isOnGround(), 99999999)
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]:
            eventPlayer.cpData[12] = true


rule "16.3: Piledriving":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    
    eventPlayer.cpData[14] = true
    waitUntil(eventPlayer.isOnGround(), 99999999)
    eventPlayer.cpData[14] = false


rule "16.4: Reset Useless Grapple/Jump/Bhop":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition (eventPlayer.cpData[9] or eventPlayer.cpData[11] or eventPlayer.cpData[12]) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isOnGround() == true
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) <= eventPlayer.cpData[1]
    
    if eventPlayer.cpData[2]:
        eventPlayer.cpData[9] = false
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    eventPlayer.cpData[11] = false
    eventPlayer.cpData[12] = false
    eventPlayer.cpData[13] = false


rule "17.1: Checkpoint Mistake: Missed Checkpoint":
    @Event eachPlayer
    @Condition eventPlayer.isInFreemode == false
    @Condition (eventPlayer.cpData[4] == null or not eventPlayer.cpData[8] and not eventPlayer.cpData[9] or eventPlayer.cpData[13]) == true
    @Condition (eventPlayer.isOnGround() or eventPlayer.cpData[10] and eventPlayer.cpData[12]) == true
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isDummy() == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[6]) >= eventPlayer.cpData[7]
    
    eventPlayer.isLoading = true
    eventPlayer.runMistakes++
    cpResetPlayer()
    if eventPlayer.isRunPaused:
        eventPlayer.isRunPaused = false
        chaseAtRate(eventPlayer.runTime, 99999999, 1)
    eventPlayer.isLoading = false


rule "17.2: Checkpoint Mistake: Already Bhopped":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.cpData[12] == true
    @Condition eventPlayer.cpData[4] == null
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[6]) >= eventPlayer.cpData[7]
    
    eventPlayer.isLoading = true
    eventPlayer.runMistakes++
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "17.3: Checkpoint Mistake: Environment Death":
    @Event playerDied
    
    eventPlayer.isLoading = true
    if not eventPlayer.isInLobby:
        eventPlayer.cpData[15] = eventPlayer.getPosition()
        eventPlayer.respawn()
        if not eventPlayer.isInFreemode:
            cpResetPlayer()
            eventPlayer.runMistakes++
        else:
            eventPlayer.teleport(nearestWalkablePosition(eventPlayer.cpData[15]))
    else:
        eventPlayer.respawn()
        loadLobby()
    eventPlayer.isLoading = false


rule "18.1: Bounce Checkpoints: Grapple Use":
    @Event eachPlayer
    @Condition eventPlayer.cpData[4] != null
    @Condition eventPlayer.cpData[9] == true
    
    if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) <= eventPlayer.cpData[1]:
        eventPlayer.cpData[8] = false
        eventPlayer.cpData[9] = false
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    else:
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
        eventPlayer.setSecondaryFireEnabled(false)
        wait()


rule "18.2: Bounce Checkpoint Mistake: No Grapple":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.cpData[4] != null
    @Condition eventPlayer.cpData[8] == false
    @Condition eventPlayer.cpData[9] == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]
    
    eventPlayer.isLoading = true
    eventPlayer.runMistakes++
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "18.3: Bounce Checkpoint Mistake: Too Slow":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.cpData[4] != null
    @Condition eventPlayer.cpData[9] == true
    @Condition eventPlayer.cpData[13] == false
    @Condition eventPlayer.getSpeed() <= 10
    @Condition eventPlayer.isInFreemode == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]
    
    eventPlayer.runMistakes++
    eventPlayer.isLoading = true
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "18.4: Bounce Checkpoint: Bounce Used Properly":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.cpData[4] != null
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.isInFreemode == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[4]) <= eventPlayer.cpData[5]
    
    eventPlayer.cpData[13] = true


rule "18.5: Bounce Checkpoint Mistake: Improperly Airborne":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.cpData[4] != null
    @Condition eventPlayer.cpData[13] == false
    @Condition eventPlayer.isJumping() == true
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]
    @Condition distance(vect(eventPlayer.getPosition().x, eventPlayer.cpData[4].y, eventPlayer.getPosition().z), eventPlayer.cpData[4]) >= eventPlayer.cpData[5]
    
    eventPlayer.runMistakes++
    eventPlayer.isLoading = true
    cpResetPlayer()
    eventPlayer.isLoading = false


def cpResetPlayer():
    @Name "19: Checkpoint Reset Player"
    
    eventPlayer.isLoading = true
    stopChasingVariable(eventPlayer.cpTime)
    eventPlayer.cpTime = 0
    if eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
        eventPlayer.disallowButton(Button.SECONDARY_FIRE)
        eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.teleport(eventPlayer.cpData[0])
    eventPlayer.applyImpulse(eventPlayer.getVelocity() * -0.001, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.setStatusEffect(null, Status.ROOTED, 0.3)
    if eventPlayer.runCurrentCp < len(cps) - 1:
        if eventPlayer.cpData[4] != null:
            eventPlayer.cpData[8] = false
            eventPlayer.cpData[9] = false
            eventPlayer.cpData[13] = false
            eventPlayer.setSecondaryFireEnabled(true)
            eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
        eventPlayer.cpData[11] = false
        eventPlayer.cpData[12] = false
    eventPlayer.isLoading = false


rule "20.1: Checkpoint Completed (No Skipping)":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isRunLoaded == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isRunPaused == false
    @Condition (eventPlayer.isOnGround() or eventPlayer.cpData[10] or eventPlayer.getAltitude() <= 0.02 and not eventPlayer.cpData[14]) == true
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[6]) <= eventPlayer.cpData[7]
    
    stopChasingVariable(eventPlayer.cpTime)
    eventPlayer.cpTimeFormatted = (
        "{}:{}:{}".format(
            floor(eventPlayer.cpTime / 3600),
            (eventPlayer.cpTime % 3600 / 60 + 100).substring(1, 2),
            (eventPlayer.cpTime % 60 + 100).substring(1, 9999)
        ) if eventPlayer.cpTime >= 3600 else
        "{}:{}".format(
            floor(eventPlayer.cpTime / 60),
            (eventPlayer.cpTime % 60 + 100).substring(1, 9999)
        ) if eventPlayer.cpTime >= 60 else
        "{}.{}".format(
            floor(eventPlayer.cpTime),
            (round(eventPlayer.cpTime % 1 * 100) + 100).substring(1, 2)
        )
    )
    smallMessage(eventPlayer, "Time: {}".format(eventPlayer.cpTimeFormatted))
    eventPlayer.isLoading = true
    eventPlayer.runCurrentCp++
    loadCp()
    if eventPlayer.runCurrentCp < len(cps) - 1:
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]:
            eventPlayer.isLoading = true
            eventPlayer.teleport(eventPlayer.cpData[0])
            eventPlayer.applyImpulse(eventPlayer.getVelocity() * -0.001, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
            eventPlayer.isLoading = false
        playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, null, eventPlayer, 100)
    else:
        finalCpReached()
    destroyInWorldText(eventPlayer.nameplateObject)
    loadNameplate()
    eventPlayer.isLoading = false


def finalCpReached():
    @Name "20.2: Final Checkpoint Reached"
    
    playEffect(eventPlayer, DynamicEffect.BAD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 200)
    playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer, 100)
    if not eventPlayer.isRunFinished:
        eventPlayer.isRunFinished = true
        async(loadRunCompletionText, AsyncBehavior.RESTART)
    eventPlayer.isInFreemode = true
    destroyInWorldText(eventPlayer.nameplateObject)
    loadNameplate()
    unloadFreemodeHud()
    loadFreemodeHud()
    if eventPlayer.isHoldingButton(Button.ULTIMATE):
        destroyHudText(eventPlayer.ctrlsHud)
        loadCtrlsHud()
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if eventPlayer.isRunLegit:
            if settings_[1]:
                updateStats()


def loadRunCompletionText():
    @Name "20.3.1: Load Run Completion Text"

    eventPlayer.runCompletionText = []
    hudSubheader(eventPlayer, "\n\nCongrats, {}!\n".format(eventPlayer), HudPosition.TOP, 2, Color.TURQUOISE, HudReeval.NONE)    
    eventPlayer.runCompletionText[len(eventPlayer.runCompletionText)] = getLastCreatedText()
    hudSubheader(eventPlayer, "Time: {}".format(eventPlayer.runTimeFormatted), HudPosition.TOP, 3, Color.ORANGE, HudReeval.NONE)
    eventPlayer.runCompletionText[len(eventPlayer.runCompletionText)] = getLastCreatedText()
    hudSubheader(eventPlayer, "Time to Beat: {}".format("00:00.00" if timeToBeatInMs == 0 else
            "{}:{}:{}".format(
                floor(elapsedTime / 3600000),
                (elapsedTime % 3600000 / 60000 + 100).substring(1, 2),
                (elapsedTime % 60000 / 1000 + 100).substring(1, 9999)
            ) if elapsedTime >= 3600000 else
            "{}:{}".format(
                floor(elapsedTime / 60000),
                (elapsedTime % 60000 / 1000 + 100).substring(1, 9999)
            ) if elapsedTime >= 60000 else
            "{}.{}".format(
                floor(elapsedTime / 1000),
                (elapsedTime % 1000 / 10 + 100).substring(1, 2)
            )
        ), HudPosition.TOP, 4, Color.ORANGE, HudReeval.NONE
    )
    eventPlayer.runCompletionText[len(eventPlayer.runCompletionText)] = getLastCreatedText()
    hudSubheader(eventPlayer, "Mistakes: {}\n".format(eventPlayer.runMistakes), HudPosition.TOP, 5, Color.ORANGE, HudReeval.NONE)
    eventPlayer.runCompletionText[len(eventPlayer.runCompletionText)] = getLastCreatedText()
    hudSubheader(eventPlayer, 
        "                <fgEC9900FF>Top-10 Time!</fg>\n"
        "<fgA52A2AFF>Submit a Video of Your Run\n"
        "                        @\n"
        "              ballkour.com</fg>\n\n"
        "       <fg00E697FF>Thanks for Playing!</fg>"
    , HudPosition.TOP, 6, Color.WHITE, HudReeval.NONE)
    eventPlayer.runCompletionText[len(eventPlayer.runCompletionText)] = getLastCreatedText()
    wait(30)
    unloadRunCompletionText()


def unloadRunCompletionText():
    @Name "20.3.2: Unload Run Completion Text"
    
    for eventPlayer.index in range(len(eventPlayer.runCompletionText)):
        destroyHudText(eventPlayer.runCompletionText[eventPlayer.index])

        
def updateStats():
    @Name "20.4: Update Lobby Stats With New Run"
    
    lobbyStats[2]++
    lobbyStats[3] += eventPlayer.runTime
    lobbyStats[4] = (
        "{}:{}:{}".format(
            floor(lobbyStats[3] / 3600),
            (lobbyStats[3] % 3600 / 60 + 100).substring(1, 2),
            (lobbyStats[3] % 60 + 100).substring(1, 9999)
        ) if lobbyStats[3] >= 3600 else
        "{}:{}".format(
            floor(lobbyStats[3] / 60),
            (lobbyStats[3] % 60 + 100).substring(1, 9999)
        ) if lobbyStats[3] >= 60 else
        "{}.{}".format(
            floor(lobbyStats[3]),
            (round(lobbyStats[3] % 1 * 100) + 100).substring(1, 2)
        )
    )
    lobbyStats[5] += eventPlayer.runMistakes
    lobbyStats[6] = lobbyStats[3] / lobbyStats[2]
    lobbyStats[7] = (
        "{}:{}:{}".format(
            floor(lobbyStats[6] / 3600),
            (lobbyStats[6] % 3600 / 60 + 100).substring(1, 2),
            (lobbyStats[6] % 60 + 100).substring(1, 9999)
        ) if lobbyStats[6] >= 3600 else
        "{}:{}".format(
            floor(lobbyStats[6] / 60),
            (lobbyStats[6] % 60 + 100).substring(1, 9999)
        ) if lobbyStats[6] >= 60 else
        "{}.{}".format(
            floor(lobbyStats[6]),
            (round(lobbyStats[6] % 1 * 100) + 100).substring(1, 2)
        )
    )
    lobbyStats[8] = lobbyStats[5] / lobbyStats[2]


rule "21.1: Controls HUD Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isInLobby == false
    
    loadCtrlsHud()
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ABILITY_2)
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE) or eventPlayer.isInLobby, 99999999)
    destroyHudText(eventPlayer.ctrlsHud)
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.ABILITY_2)


def loadCtrlsHud():
    @Name "21.2: Load Controls HUD"
    
    if eventPlayer.runCurrentCp < len(cps) - 1:
        hudSubheader(eventPlayer, 
            (
                "Go Back CP:          {} + {}\n"
                "Skip CP:                   {} + {}\n"
                "Restart CP:        {} (Hold)\n"
                "Restart Run:           {} + {}\n"
                "Freemode:              {} + {}\n"
                "Lobby/Pause:         {} + {}\n"
            )
            .format(
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.PRIMARY_FIRE),
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.SECONDARY_FIRE), 
                inputBindingString(Button.RELOAD),
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.RELOAD),
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.INTERACT),
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.ABILITY_2)
            ), 
            HudPosition.LEFT, 1, rgb(165, 42, 42), HudReeval.STRING
        )
    else:
        hudSubheader(eventPlayer, 
            "Go Back CP:          {} + {}"
            "Restart Run:           {} + {}"
            "Lobby/Pause:         {} + {}"
            .format(
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.PRIMARY_FIRE),
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.RELOAD),
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.INTERACT),
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.ABILITY_2)
            ), 
            HudPosition.LEFT, 1, rgb(165, 42, 42), HudReeval.STRING
        )
    eventPlayer.ctrlsHud = getLastCreatedText()


rule "21.3: Go Back Checkpoint Input":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.runCurrentCp > 0
    @Condition eventPlayer.isInLobby == false
    
    eventPlayer.isLoading = true
    eventPlayer.isRunLegit = false
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    eventPlayer.runCurrentCp--
    if eventPlayer.runCurrentCp == len(cps) - 2:
        unloadFreemodeHud()
        loadFreemodeHud()
        destroyHudText(eventPlayer.ctrlsHud)
        loadCtrlsHud()
    loadCp()
    cpResetPlayer()
    destroyInWorldText(eventPlayer.nameplateObject)
    loadNameplate()
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[6]), Relativity.TO_WORLD)
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE) or not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE), 0.25)
    if eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.runCurrentCp > 0:
        eventPlayer.isLoading = true
        while eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.runCurrentCp > 0:
            eventPlayer.runCurrentCp--
            eventPlayer.teleport(cps[eventPlayer.runCurrentCp][0])
            wait(0.02)
        loadCp()
        cpResetPlayer()
        destroyInWorldText(eventPlayer.nameplateObject)
        loadNameplate()
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[6]), Relativity.TO_WORLD)


rule "21.4: Skip Checkpoint Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    @Condition eventPlayer.isInLobby == false
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    
    eventPlayer.isLoading = true
    eventPlayer.isRunLegit = false
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    eventPlayer.runCurrentCp++
    loadCp()
    cpResetPlayer()
    destroyInWorldText(eventPlayer.nameplateObject)
    loadNameplate()
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[6]), Relativity.TO_WORLD)
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE) or not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE), 0.25)
    if eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and eventPlayer.runCurrentCp < len(cps) - 1:
        eventPlayer.isLoading = true
        while eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and eventPlayer.runCurrentCp < len(cps) - 1:
            eventPlayer.runCurrentCp++
            eventPlayer.teleport(cps[eventPlayer.runCurrentCp][0])
            wait(0.02)
        loadCp()
        cpResetPlayer()
        destroyInWorldText(eventPlayer.nameplateObject)
        loadNameplate()
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[6]), Relativity.TO_WORLD)
    if eventPlayer.runCurrentCp == len(cps) - 1:
        finalCpReached()


rule "21.5: Restart Checkpoint Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    @Condition eventPlayer.isInLobby == false
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    
    waitUntil(not eventPlayer.isHoldingButton(Button.RELOAD), 0.2)
    if not eventPlayer.isHoldingButton(Button.RELOAD) and eventPlayer.runCurrentCp < len(cps) - 1:
        return
    if not eventPlayer.isRunPaused:
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    eventPlayer.isLoading = true
    cpResetPlayer()


rule "21.6: Restart Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.isInLobby == false
    
    eventPlayer.isLoading = true
    stopChasingVariable(eventPlayer.runTime)
    newRun()
    unloadFreemodeHud()
    unloadRunCompletionText()
    destroyHudText(eventPlayer.ctrlsHud)
    if eventPlayer.isHoldingButton(Button.ULTIMATE):
        loadCtrlsHud()
    destroyInWorldText(eventPlayer.nameplateObject)
    loadNameplate()
    eventPlayer.isLoading = false


rule "21.7.1: Freemode Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    
    if not eventPlayer.isInFreemode:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        eventPlayer.isRunLegit = false
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.isInFreemode = true
        unloadFreemodeHud()
        loadFreemodeHud()
    else:
        eventPlayer.isLoading = true
        eventPlayer.isInFreemode = false
        unloadFreemodeHud()
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]:
            cpResetPlayer()
        eventPlayer.setSecondaryFireEnabled(eventPlayer.cpData[2])
        if not eventPlayer.cpData[3]:
            eventPlayer.disallowButton(Button.CROUCH)
        else:
            eventPlayer.allowButton(Button.CROUCH)
        eventPlayer.isLoading = false
    destroyInWorldText(eventPlayer.nameplateObject)
    loadNameplate()


def loadFreemodeHud():
    @Name "21.7.2.1: Load Freemode HUD"
    
    eventPlayer.freemodeHud = []
    hudSubtext(eventPlayer, "\n\n\n\n\nFreemode On", HudPosition.LEFT, 11, Color.ORANGE, HudReeval.NONE)
    eventPlayer.freemodeHud[0] = getLastCreatedText()
    if eventPlayer.runCurrentCp < len(cps) - 1:
        hudSubtext(eventPlayer, "Disable: {} + {}".format(inputBindingString(Button.ULTIMATE), inputBindingString(Button.INTERACT)), HudPosition.LEFT, 12, rgb(165, 42, 42), HudReeval.STRING)
        eventPlayer.freemodeHud[1] = getLastCreatedText()
    else:
        hudSubtext(eventPlayer, "Restart: {} + {}".format(inputBindingString(Button.ULTIMATE), inputBindingString(Button.RELOAD)), HudPosition.LEFT, 12, rgb(165, 42, 42), HudReeval.STRING)
        eventPlayer.freemodeHud[1] = getLastCreatedText()


def unloadFreemodeHud():
    @Name "21.7.2.2: Unload Freemode HUD"
    
    for eventPlayer.index in range(len(eventPlayer.freemodeHud)):
        destroyHudText(eventPlayer.freemodeHud[eventPlayer.index])


rule "21.8: Lobby Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.isInLobby == false
    
    eventPlayer.isLoading = true
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) >= eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    unloadCpObjects()
    unloadHud()
    unloadFreemodeHud()
    unloadRunCompletionText()
    loadLobby()
    eventPlayer.isLoading = false


rule "23.1: Auto-Restart Server":
    @SuppressWarnings w_ow2_rule_condition_chase
    #3hr29min in
    @Condition elapsedTime >= 12540
    
    chaseAtRate(elapsedTime, 99999999, 1)
    bigMessage(getAllPlayers(), "Server restart: \n30min")
    wait(900)
    bigMessage(getAllPlayers(), "Server restart: \n15min")
    wait(600)
    bigMessage(getAllPlayers(), "Server restart: \n5min")
    wait(240)
    bigMessage(getAllPlayers(), "Server restart: \n1min")
    wait(60)
    #3hr59min in
    restartMatch()
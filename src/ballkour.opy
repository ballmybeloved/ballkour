#!mainFile "main.opy"
#!setupTags

rule "6.1: Initialize Match":
    disableAnnouncer()
    disableGamemodeCompletion()
    setMatchTime(0)
    if not settings_[0]:
        disableInspector()
    if settings_[1]:
        players = []
        # lobbyStats[i]: [0]players [1]rejoins [2]legitRuns [3]totalRunTime [4]totalRunTimeFormatted [5]totalMistakes [6]avgRunTime [7]avgRunTimeFormatted [8]avgMistakes
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
    lbObj = lb[10].split(",")[1].replace(" ", "").split(":")
    lbObjFormatted = lbObj[len(lbObj) - 1].split(".")
    timeToBeatInMs = (
        (
            (["0","1","2","3","4","5","6","7","8","9"].index(lbObj[0].substring(0, 1)) * 10
             + ["0","1","2","3","4","5","6","7","8","9"].index(lbObj[0].substring(1, 1)))
            if ["0","1","2","3","4","5","6","7","8","9"].index(lbObj[0].substring(1, 1)) >= 0 else
            ["0","1","2","3","4","5","6","7","8","9"].index(lbObj[0].substring(0, 1))
        ) * 3600000 if len(lbObj) >= 3 else 0
        + (
            (["0","1","2","3","4","5","6","7","8","9"].index(lbObj[len(lbObj) - 2].substring(0, 1)) * 10
             + ["0","1","2","3","4","5","6","7","8","9"].index(lbObj[len(lbObj) - 2].substring(1, 1)))
            if ["0","1","2","3","4","5","6","7","8","9"].index(lbObj[len(lbObj) - 2].substring(1, 1)) >= 0 else
            ["0","1","2","3","4","5","6","7","8","9"].index(lbObj[len(lbObj) - 2].substring(0, 1))
        ) * 60000
        + (
            (["0","1","2","3","4","5","6","7","8","9"].index(lbObjFormatted[0].substring(0, 1)) * 10
             + ["0","1","2","3","4","5","6","7","8","9"].index(lbObjFormatted[0].substring(1, 1)))
            if ["0","1","2","3","4","5","6","7","8","9"].index(lbObjFormatted[0].substring(1, 1)) >= 0 else
            ["0","1","2","3","4","5","6","7","8","9"].index(lbObjFormatted[0].substring(0, 1))
        ) * 1000
        + (
            (["0","1","2","3","4","5","6","7","8","9"].index(lbObjFormatted[1].substring(0, 1)) * 10
             + ["0","1","2","3","4","5","6","7","8","9"].index(lbObjFormatted[1].substring(1, 1)))
            if ["0","1","2","3","4","5","6","7","8","9"].index(lbObjFormatted[1].substring(1, 1)) >= 0 else
            ["0","1","2","3","4","5","6","7","8","9"].index(lbObjFormatted[1].substring(0, 1))
        ) * 10
    )


rule "6.3: Start Elapsed Timer":
    chaseAtRate(elapsedTime, 14340, 1)
    if settings_[1] and not settings_[0]:
        while true:
            wait(0.1)
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


rule "6.4: Destroy Disruptive Environment":
    # dd[i]: [0]nextDd [1]batchSize [2]currentDdIndex [3]ddEntity
    dd = [1, 0, 0, 0]
    while dd[0] < len(ddBots):
        dd[1] = min(12 - len(getAllPlayers()), len(ddBots) - dd[0])
        if dd[1] <= 0:
            wait(5)
        else:
            dd[2] = 0
            while dd[2] < dd[1]:
                createDummy(Hero.LUCIO, ddBots[0], -1, ddBots[dd[0] + dd[2]][0], directionTowards(ddBots[dd[0] + dd[2]][0], ddBots[dd[0] + dd[2]][1]))
                dd[3] = getLastCreatedEntity()
                dd[3].startForcingName("Disrupter Destructor {}".format(dd[0] + dd[2]))
                dd[2] = dd[2] + 1
            dd[2] = 0
            while dd[2] < dd[1]:
                waitUntil(getAllPlayers().filter(lambda p: p.isDummy())[dd[2]].hasSpawned(), 5)
                getAllPlayers().filter(lambda p: p.isDummy())[dd[2]].forceButtonPress(Button.SECONDARY_FIRE)
                dd[2] = dd[2] + 1
            wait()
            destroyAllDummies()
            dd[0] = dd[0] + dd[1]


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
    waitUntil(eventPlayer.hasSpawned(), Math.INFINITY)
    eventPlayer.disableGamemodeHud()
    eventPlayer.disableKillFeed()
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disablePlayerCollision()
    eventPlayer.setDamageDealt(false)
    eventPlayer.disableNameplatesFor(getAllPlayers())
    getAllPlayers().disableNameplatesFor(eventPlayer)
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer != eventPlayer), eventPlayer.nameplate, eventPlayer, 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING)
    wait()
    loadLobby()
    while angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), lobbyData[1])) > 1:
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), lobbyData[1]), Relativity.TO_WORLD)
        wait()
    eventPlayer.isLoading = false


rule "7.2: Player Leaves":
    @Event playerLeft
    
    enableFreecamForAffectedSpecs()
            

def loadLobby():
    @Name "8.1: Load Lobby"
    
    eventPlayer.teleport(lobbyData[0])
    eventPlayer.applyImpulse(eventPlayer.getVelocity() * -0.001, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.setStatusEffect(null, Status.ROOTED, 0.3)
    eventPlayer.isInLobby = true
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), lobbyData[1]), Relativity.TO_WORLD)
    eventPlayer.isInFreemode = false
    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.allowButton(Button.CROUCH)
    eventPlayer.nameplate = "{}".format(eventPlayer)
    wait()


rule "8.2: Load Welcome Area":
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), "Welcome to", lobbyData[2], lobbyData[4], Clip.SURFACES, WorldTextReeval.VISIBILITY, rgb(230, 151, 0))
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), "Ballkour!", lobbyData[3], lobbyData[4], Clip.SURFACES, WorldTextReeval.VISIBILITY, rgb(230, 151, 0))


rule "8.3: Load Leaderboard Area":
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), "Leaderboard", lobbyData[11], lobbyData[12], Clip.SURFACES, WorldTextReeval.VISIBILITY, rgb(230, 151, 0))
    # 1st-9th Position Placeholder"
    lb[11] = "---, -:--.--, -, '                                               '"
    # 10th Position Placeholder"
    lb[12] = "---, -:--.--, -, '                                              '"
    for index in range(1, 11):
        if lb[index] == null:
            if index <= 9:
                lbObj = lb[11]
            else:
                lbObj = lb[12]
        else:
            lbObj = lb[index]
        # lbObj[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator
        lbObj = lbObj.split(",")
        lbObj[3] = lbObj[3].replace("'", "")
        if index == 1:
            lbObjFormatted = "{}. <fgFFFF00FF>{}</fg>{}({}<fgFFFF00FF>{}, {}{}</fg>)".format(index, lbObj[0], lbObj[3], iconString(Icon.BOLT), lbObj[1], iconString(Icon.SKULL), lbObj[2])
        elif index == 2:
            lbObjFormatted = "{}. <fgC0C0C0FF>{}</fg>{}({}<fgC0C0C0FF>{}, {}{}</fg>)".format(index, lbObj[0], lbObj[3], iconString(Icon.BOLT), lbObj[1], iconString(Icon.SKULL), lbObj[2])
        elif index == 3:
            lbObjFormatted = "{}. <fgCD7F32FF>{}</fg>{}({}<fgCD7F32FF>{}, {}{}</fg>)".format(index, lbObj[0], lbObj[3], iconString(Icon.BOLT), lbObj[1], iconString(Icon.SKULL), lbObj[2])
        elif index >= 4:
            lbObjFormatted = "{}. <fg00E697FF>{}</fg>{}({}<fg00E697FF>{}, {}{}</fg>)".format(index, lbObj[0], lbObj[3], iconString(Icon.BOLT), lbObj[1], iconString(Icon.SKULL), lbObj[2])
        createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), lbObjFormatted, lbPos[index], lobbyData[13], Clip.SURFACES, WorldTextReeval.VISIBILITY, rgb(230, 151, 0))


rule "8.4.1: Load Start Run Area":
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), "New Run", lobbyData[7], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.TURQUOISE)
    createEffect(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), Effect.RING, Color.AQUA, lobbyData[5], 1.6, EffectReeval.VISIBILITY)
    createIcon(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), lobbyData[6], Icon.FLAG, IconReeval.VISIBILITY, Color.GREEN, false)
    createEffect(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), Effect.SPARKLES, rgb(230, 151, 0), lobbyData[5] + vect(0, -0.85, 0), 1.6, EffectReeval.VISIBILITY)


rule "8.4.2: Start Run Circle Entry":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInLobby == true
    @Condition distance(eventPlayer.getPosition(), lobbyData[5]) <= 2
    
    eventPlayer.isInLobby = false
    eventPlayer.isLoading = true
    newRun()
    eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
    eventPlayer.isLoading = false


rule "8.5.1: Load Resume Run Area":
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and localPlayer.isRunLoaded and not localPlayer.isRunFinished), "Resume Run", lobbyData[10], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.TURQUOISE)
    createEffect(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and localPlayer.isRunLoaded and not localPlayer.isRunFinished), Effect.RING, Color.GREEN, lobbyData[8], 1.6, EffectReeval.VISIBILITY)
    createIcon(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and localPlayer.isRunLoaded and not localPlayer.isRunFinished), lobbyData[9], Icon.RECYCLE, IconReeval.VISIBILITY, Color.GREEN, false)
    createEffect(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and localPlayer.isRunLoaded and not localPlayer.isRunFinished), Effect.SPARKLES, rgb(230, 151, 0), lobbyData[8] + vect(0, -0.85, 0), 1.6, EffectReeval.VISIBILITY)


rule "8.5.2: Resume Run Circle Entry":
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
    eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), cps[eventPlayer.runCurrentCp][7]), Relativity.TO_WORLD)
    eventPlayer.isLoading = false


rule "8.6: Load Lobby Stats":
    @Condition settings_[1] == true
    
    createInWorldText(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), 
        "Stats", lobbyData[14], lobbyData[15], Clip.SURFACES, WorldTextReeval.VISIBILITY, rgb(230, 151, 0))
    createInWorldText(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), 
        "Elapsed Time: {}".format(elapsedTimeFormatted if not settings_[0] else elapsedTime), lobbyData[17], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.TURQUOISE)
    createInWorldText(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), 
        "New Players: {}".format(lobbyStats[0]), lobbyData[18], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.TURQUOISE)
    createInWorldText(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), 
        "Rejoins: {}".format(lobbyStats[1]), lobbyData[19], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.TURQUOISE)
    createInWorldText(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), 
        "Legit Runs: {}".format(lobbyStats[2]), lobbyData[20], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.TURQUOISE)
    createInWorldText(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), 
        "Total Run Time: {}".format(lobbyStats[4]), lobbyData[21], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.TURQUOISE)
    createInWorldText(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), 
        "Total Mistakes: {}".format(lobbyStats[5]), lobbyData[22], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.TURQUOISE)
    createInWorldText(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), 
        "Avg Run Time: {}".format(lobbyStats[7]), lobbyData[23], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.TURQUOISE)
    createInWorldText(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), 
        "Avg Mistakes: {}".format(lobbyStats[8]), lobbyData[24], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.TURQUOISE)


rule "9: Clear Unused Variables":
    lb = null
    lbPos = null
    lbObj = null
    lbObjFormatted = null


rule "10: Load Run HUD":
    hudSubtext(getAllPlayers(), "ballkour.com", HudPosition.TOP, 0, rgb(230, 36, 0), HudReeval.VISIBILITY)
    hudSubtext(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby), 
        ("\n\n\n\nControls: {}").format(inputBindingString(Button.ULTIMATE)), HudPosition.LEFT, 0, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING)
    # Non-Spectating HUD
    hudSubtext(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.spectating[0]), 
        ("{}/{}").format(localPlayer.runCurrentCp, len(cps) - 1), HudPosition.TOP, 1, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING)
    if not settings_[0]:
        hudSubtext(getAllPlayers()
            .filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.spectating[0]), 
            ("\n\n\n\n{} {}\n").format(iconString(Icon.BOLT), localPlayer.runTimeFormatted), HudPosition.RIGHT, 1, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING)
    else:
        hudSubtext(getAllPlayers()
            .filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.spectating[0]), 
            ("\n\n\n\n{} {}\n").format(iconString(Icon.BOLT), localPlayer.runTime), HudPosition.RIGHT, 1, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.spectating[0]), 
        ("{} {}").format(iconString(Icon.SKULL), localPlayer.runMistakes), HudPosition.RIGHT, 2, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING)
    # Spectating HUD
    hudSubtext(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby and localPlayer.spectating[0] and not localPlayer.spectating[4]),
        ("{}/{}").format(localPlayer.spectating[1].runCurrentCp, len(cps) - 1), HudPosition.TOP, 1, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING
    )
    if not settings_[0]:
        hudSubtext(getAllPlayers()
            .filter(lambda localPlayer: not localPlayer.isInLobby and localPlayer.spectating[0] and not localPlayer.spectating[4]), 
            ("\n\n\n\n{} {}\n").format(iconString(Icon.BOLT), localPlayer.spectating[1].runTimeFormatted), HudPosition.RIGHT, 1, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING)
    else:
        hudSubtext(getAllPlayers()
            .filter(lambda localPlayer: not localPlayer.isInLobby and localPlayer.spectating[0] and not localPlayer.spectating[4]), 
            ("\n\n\n\n{} {}\n").format(iconString(Icon.BOLT), localPlayer.spectating[1].runTime), HudPosition.RIGHT, 1, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby and localPlayer.spectating[0] and not localPlayer.spectating[4]), 
        ("{} {}").format(iconString(Icon.SKULL), localPlayer.spectating[1].runMistakes), HudPosition.RIGHT, 2, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING)
    # Spectating HUD — Freecam Detached
    hudSubtext(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby and localPlayer.spectating[0] and localPlayer.spectating[4]), 
        ("{}/{}").format(localPlayer.spectating[3], len(cps) - 1), HudPosition.TOP, 1, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING)


def newRun():
    @Name "11: Initialize New Run"
    
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
    loadCpData()
    setCpAbilities()
    if eventPlayer.spectating[0]:
        disableSpectatorMode()
    cpResetPlayer()
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[7]), Relativity.TO_WORLD)


def loadCpData():
    @Name "12.1: Load Checkpoint Data"
    
    # eventPlayer.cpData[i]: [0]cpLocation [1]cpSize [2]isGrappleAllowed [3]isShieldBounceAllowed [4]isPiledriverAllowed [5]bounceLocation [6]bounceSize [7]nextCpLocation [8]nextCpSize [9]isJumping [10]hasJumped [11]hasBhopped [12]isGrappling [13]hasUsedGrapple [14]hasShieldBounced [15]isPiledriving [16]hasUsedBounceJump
    eventPlayer.cpData = []
    eventPlayer.cpData[0] = cps[eventPlayer.runCurrentCp][0]
    eventPlayer.cpData[1] = cps[eventPlayer.runCurrentCp][1]
    eventPlayer.cpData[2] = cps[eventPlayer.runCurrentCp][2]
    eventPlayer.cpData[3] = cps[eventPlayer.runCurrentCp][3]
    eventPlayer.cpData[4] = cps[eventPlayer.runCurrentCp][4]
    eventPlayer.cpData[5] = cps[eventPlayer.runCurrentCp][5]
    eventPlayer.cpData[6] = cps[eventPlayer.runCurrentCp][6]
    eventPlayer.cpData[7] = cps[eventPlayer.runCurrentCp][7]
    eventPlayer.cpData[8] = cps[eventPlayer.runCurrentCp][8]
    eventPlayer.cpData[10] = false
    eventPlayer.cpData[11] = false
    eventPlayer.cpData[13] = false
    eventPlayer.cpData[14] = false
    eventPlayer.cpData[16] = false
    eventPlayer.cpTime = 0


def setCpAbilities():
    @Name "12.2: Set Checkpoint Abilities"
    
    if eventPlayer.spectating[0]:
        return
    if eventPlayer.runCurrentCp < len(cps) - 1 and not eventPlayer.isInFreemode and not eventPlayer.spectating[0]:
        eventPlayer.setSecondaryFireEnabled(eventPlayer.cpData[2])
        eventPlayer.setAbility2Enabled(eventPlayer.cpData[3])
        if not eventPlayer.cpData[4]:
            eventPlayer.disallowButton(Button.CROUCH)
        else:
            eventPlayer.allowButton(Button.CROUCH)
    else:
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.allowButton(Button.CROUCH)
        eventPlayer.setAbility2Enabled(true)


rule "13: Load Checkpoint Objects":
    # Non-Spectating
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.spectating[0] and not localPlayer.runCurrentCp == len(cps) - 1), 
        Effect.RING, Color.GREEN, localPlayer.cpData[0], localPlayer.cpData[1], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.spectating[0] and localPlayer.cpData[5] != null and not localPlayer.runCurrentCp == len(cps) - 1), 
        Effect.RING, Color.ORANGE, localPlayer.cpData[5], localPlayer.cpData[6], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.spectating[0] and localPlayer.cpData[5] != null and not localPlayer.runCurrentCp == len(cps) - 1), 
        localPlayer.cpData[5], Icon.ARROW_UP, IconReeval.VISIBILITY_AND_POSITION, Color.YELLOW, false)
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.spectating[0] and not localPlayer.runCurrentCp == len(cps) - 1), Effect.RING, Color.AQUA, 
        localPlayer.cpData[7], localPlayer.cpData[8], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.spectating[0] and not localPlayer.runCurrentCp == len(cps) - 1), 
        localPlayer.cpData[7] - vect(0, 0.5, 0), Icon.FLAG, IconReeval.VISIBILITY_AND_POSITION, Color.GREEN)
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.spectating[0] and not localPlayer.runCurrentCp == len(cps) - 1), 
        Effect.LIGHT_SHAFT, Color.GRAY, localPlayer.cpData[7], localPlayer.cpData[8], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    # Spectating Objects
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and not localPlayer.spectating[4] and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        Effect.RING, Color.GREEN, localPlayer.spectating[1].cpData[0], localPlayer.spectating[1].cpData[1], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and not localPlayer.spectating[4] and localPlayer.cpData[5] != null and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        Effect.RING, Color.ORANGE, localPlayer.spectating[1].cpData[5], localPlayer.spectating[1].cpData[6], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and not localPlayer.spectating[4] and localPlayer.cpData[5] != null and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        localPlayer.spectating[1].cpData[5], Icon.ARROW_UP, IconReeval.VISIBILITY_AND_POSITION, Color.YELLOW, false)
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and not localPlayer.spectating[4] and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        Effect.RING, Color.AQUA, localPlayer.spectating[1].cpData[7], localPlayer.spectating[1].cpData[8], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and not localPlayer.spectating[4] and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        localPlayer.spectating[1].cpData[7] - vect(0, 0.5, 0), Icon.FLAG, IconReeval.VISIBILITY_AND_POSITION, Color.GREEN)
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and not localPlayer.spectating[4] and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        Effect.LIGHT_SHAFT, Color.GRAY, localPlayer.spectating[1].cpData[7], localPlayer.spectating[1].cpData[8], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    # Spectating Objects — Freecam Detached
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and localPlayer.spectating[4] and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        Effect.RING, Color.GREEN, cps[localPlayer.spectating[3]][0], cps[localPlayer.spectating[3]][1], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and localPlayer.spectating[4] and localPlayer.cpData[5] != null and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        Effect.RING, Color.ORANGE, cps[localPlayer.spectating[3]][5], cps[localPlayer.spectating[3]][6], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and localPlayer.spectating[4] and localPlayer.cpData[5] != null and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        cps[localPlayer.spectating[3]][5], Icon.ARROW_UP, IconReeval.VISIBILITY_AND_POSITION, Color.YELLOW, false)
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and localPlayer.spectating[4] and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        Effect.RING, Color.AQUA, cps[localPlayer.spectating[3]][7], cps[localPlayer.spectating[3]][8], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and localPlayer.spectating[4] and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        cps[localPlayer.spectating[3]][7] - vect(0, 0.5, 0), Icon.FLAG, IconReeval.VISIBILITY_AND_POSITION, Color.GREEN)
    createEffect(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and localPlayer.spectating[4] and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1), 
        Effect.LIGHT_SHAFT, Color.GRAY, cps[localPlayer.spectating[3]][7], cps[localPlayer.spectating[3]][8], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


rule "14.1: Start/Resume Run":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isRunPaused == true
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    @Condition eventPlayer.spectating[0] == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    
    eventPlayer.isRunPaused = false
    chaseAtRate(eventPlayer.runTime, Math.INFINITY, 1)


rule "14.2: Update Run Timer Format":
    @Event eachPlayer
    @Condition eventPlayer.isTimerActive == false
    @Condition eventPlayer.isRunPaused == false
    @Condition eventPlayer.isRunLoaded == true
    @Condition settings_[0] == false
    
    eventPlayer.isTimerActive = true
    while not eventPlayer.isRunPaused:
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
    eventPlayer.isTimerActive = false


rule "15.1: Start Checkpoint Time Timer":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    @Condition eventPlayer.spectating[0] == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    
    eventPlayer.isCpTimerActive = true
    chaseAtRate(eventPlayer.cpTime, Math.INFINITY, 1)


rule "15.2: Restart Checkpoint Time Timer":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isCpTimerActive == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    @Condition eventPlayer.spectating[0] == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) <= eventPlayer.cpData[1]
    
    eventPlayer.isCpTimerActive = false
    stopChasingVariable(eventPlayer.cpTime)
    eventPlayer.cpTime = 0


rule "16.1.1: Jumping":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.spectating[0] == false
    
    eventPlayer.cpData[9] = true
    eventPlayer.cpData[10] = true
    waitUntil(eventPlayer.isOnGround(), 0.016)
    eventPlayer.cpData[9] = false


rule "16.1.2: Bhopping":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isInLobby == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[7]) > eventPlayer.cpData[8]
    
    if not eventPlayer.cpData[11]:
        waitUntil(eventPlayer.isOnGround(), Math.INFINITY)
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.cpData[11] = true


rule "16.2: Grapple Use":
    @Event eachPlayer
    @Condition eventPlayer.isFiringSecondaryFire() == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.spectating[0] == false
    
    if not (eventPlayer.isInLobby or eventPlayer.cpData[5] == null or eventPlayer.isInFreemode):
        eventPlayer.cpData[12] = true
        waitUntil(not eventPlayer.isFiringSecondaryFire() or eventPlayer.getSpeed() >= 15, Math.INFINITY)
        if eventPlayer.getSpeed() >= 15:
            waitUntil(not eventPlayer.isFiringSecondaryFire(), 8.5)
        eventPlayer.cpData[12] = false
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.cpData[13] = true
        waitUntil(not eventPlayer.isFiringSecondaryFire(), Math.INFINITY)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    elif not eventPlayer.isInLobby and not eventPlayer.isInFreemode:
        waitUntil(not eventPlayer.isFiringSecondaryFire(), Math.INFINITY)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    if (not eventPlayer.isInLobby and eventPlayer.cpData[5] != null and not eventPlayer.isInFreemode):
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.setSecondaryFireEnabled(false)
        else:
            eventPlayer.cpData[13] = false
        waitUntil(not eventPlayer.isFiringSecondaryFire(), Math.INFINITY)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    elif (eventPlayer.isInLobby or eventPlayer.isInFreemode):
        waitUntil(not eventPlayer.isFiringSecondaryFire(), Math.INFINITY)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)


rule "16.3: Shield Bounce Use":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition ((eventPlayer.isInLobby or eventPlayer.isInFreemode) or (eventPlayer.cpData[3] and not eventPlayer.cpData[14])) == true

    eventPlayer.applyImpulse(Vector.UP, (10 - 1.25 * max(0, eventPlayer.getSpeed() - 10)) if eventPlayer.getSpeed() < 18 else 0, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.applyImpulse(normalize(vect(eventPlayer.getVelocity().x, 0, eventPlayer.getVelocity().z)), min(distance(vect(0,0,0), vect(eventPlayer.getVelocity().x, 0, eventPlayer.getVelocity().z)), 10) * 0.5 + max(0, min(distance(vect(0,0,0), vect(eventPlayer.getVelocity().x, 0, eventPlayer.getVelocity().z)), 20) - 10) * 0.2, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    eventPlayer.setHealth(575)
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
    if eventPlayer.isInLobby or eventPlayer.isInFreemode:
        eventPlayer.setAbility2Enabled(true)
    elif eventPlayer.cpData[3] and not eventPlayer.cpData[14]:
        eventPlayer.cpData[14] = true
        eventPlayer.setAbility2Enabled(false)


rule "16.4: Piledriving":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.spectating[0] == false
    
    eventPlayer.cpData[15] = true
    waitUntil(eventPlayer.isOnGround(), Math.INFINITY)
    eventPlayer.cpData[15] = false


rule "16.5: Reset Useless Jump/Grapple/Shield Bounce/Bhop":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition (eventPlayer.cpData[10] or eventPlayer.cpData[11] or eventPlayer.cpData[13] or eventPlayer.cpData[14]) == true
    @Condition eventPlayer.isInLobby == false
    @Condition (eventPlayer.isOnGround() or eventPlayer.cpData[9]) == true
    @Condition eventPlayer.spectating[0] == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) <= eventPlayer.cpData[1]

    if eventPlayer.cpData[2]:
        eventPlayer.cpData[13] = false
        eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.cpData[10] = false
    eventPlayer.cpData[11] = false
    eventPlayer.cpData[16] = false
    wait()
    if eventPlayer.cpData[3]:
        eventPlayer.cpData[14] = false
        if not eventPlayer.isHoldingButton(Button.ABILITY_2):
            eventPlayer.setAbility2Enabled(true)
        eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)


rule "17.1: Checkpoint Mistake: Missed Checkpoint":
    @Event eachPlayer
    @Condition eventPlayer.isInFreemode == false
    @Condition (eventPlayer.cpData[5] == null or (not eventPlayer.cpData[12] and not eventPlayer.cpData[13]) or (eventPlayer.cpData[16] and distance(vect(eventPlayer.getPosition().x, eventPlayer.cpData[5].y, eventPlayer.getPosition().z), eventPlayer.cpData[5]) > eventPlayer.cpData[6])) == true
    @Condition (eventPlayer.isOnGround() or eventPlayer.cpData[9] and eventPlayer.cpData[11]) == true
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.spectating[0] == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[7]) > eventPlayer.cpData[8]
    @Condition eventPlayer.isDummy() == false
    
    eventPlayer.isLoading = true
    eventPlayer.runMistakes++
    cpResetPlayer()
    if eventPlayer.isRunPaused:
        eventPlayer.isRunPaused = false
        chaseAtRate(eventPlayer.runTime, Math.INFINITY, 1)
    eventPlayer.isLoading = false


rule "17.2: Checkpoint Mistake: Already Bhopped":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.cpData[11] == true
    @Condition eventPlayer.cpData[5] == null
    @Condition eventPlayer.spectating[0] == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[7]) > eventPlayer.cpData[8]
    
    eventPlayer.isLoading = true
    eventPlayer.runMistakes++
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "17.3: Checkpoint Mistake: Environment Death":
    @Event playerDied
    @Condition (eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.ABILITY_1)) == false
    @Condition eventPlayer.spectating[0] == false
    
    eventPlayer.isLoading = true
    if not eventPlayer.isInLobby:
        if not eventPlayer.isInFreemode and not eventPlayer.spectating[0]:
            cpResetPlayer()
            eventPlayer.runMistakes++
        else:
            eventPlayer.teleport(nearestWalkablePosition(eventPlayer.getPosition()))
        eventPlayer.resurrect()
    else:
        eventPlayer.resurrect()
        loadLobby()
    eventPlayer.isLoading = false


rule "18.1: Bounce Checkpoint Mistake: No Grapple":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.cpData[12] == false
    @Condition eventPlayer.cpData[13] == false
    @Condition eventPlayer.spectating[0] == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    
    eventPlayer.isLoading = true
    eventPlayer.runMistakes++
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "18.2: Bounce Checkpoint Mistake: Too Slow":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.cpData[13] == true
    @Condition (not eventPlayer.cpData[16] or (eventPlayer.cpData[16] and eventPlayer.isOnGround() and distance(vect(eventPlayer.getPosition().x, eventPlayer.cpData[5].y, eventPlayer.getPosition().z), eventPlayer.cpData[5]) <= eventPlayer.cpData[6])) == true
    @Condition eventPlayer.getSpeed() <= 10
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.spectating[0] == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    
    eventPlayer.runMistakes++
    eventPlayer.isLoading = true
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "18.3: Bounce Checkpoint: Bounce Used Properly":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.spectating[0] == false
    @Condition distance(vect(eventPlayer.getPosition().x, eventPlayer.cpData[5].y, eventPlayer.getPosition().z), eventPlayer.cpData[5]) <= eventPlayer.cpData[6]
    
    eventPlayer.cpData[16] = true


rule "18.4: Bounce Checkpoint Mistake: Improperly Airborne":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.cpData[16] == false
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.spectating[0] == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    @Condition distance(vect(eventPlayer.getPosition().x, eventPlayer.cpData[5].y, eventPlayer.getPosition().z), eventPlayer.cpData[5]) > eventPlayer.cpData[6]
    
    eventPlayer.runMistakes++
    eventPlayer.isLoading = true
    cpResetPlayer()
    eventPlayer.isLoading = false


def cpResetPlayer():
    @Name "19: Checkpoint Reset Player"
    
    eventPlayer.isLoading = true
    stopChasingVariable(eventPlayer.cpTime)
    eventPlayer.cpTime = 0
    if not eventPlayer.spectating[0]:
        eventPlayer.teleport(eventPlayer.cpData[0])
    else:
        eventPlayer.teleport(cps[eventPlayer.spectating[3]][0])
    eventPlayer.applyImpulse(eventPlayer.getVelocity() * -0.001, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.setStatusEffect(null, Status.ROOTED, 0.3)
    if eventPlayer.runCurrentCp < len(cps) - 1:
        if eventPlayer.cpData[5] != null:
            eventPlayer.cpData[13] = false
            eventPlayer.setSecondaryFireEnabled(true)
            eventPlayer.cpData[16] = false
        eventPlayer.cpData[10] = false
        eventPlayer.cpData[11] = false
        eventPlayer.cpData[14] = false
        eventPlayer.setAbility2Enabled(eventPlayer.cpData[3])
    eventPlayer.isLoading = false


rule "20: Checkpoint Completed (No Skipping)":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isRunLoaded == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isRunPaused == false
    @Condition (eventPlayer.isOnGround() or eventPlayer.cpData[9] or eventPlayer.getAltitude() <= 0.02 and not eventPlayer.cpData[15]) == true
    @Condition eventPlayer.spectating[0] == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[7]) <= eventPlayer.cpData[8]
    
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
    eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
    loadCpData()
    setCpAbilities()
    if eventPlayer.runCurrentCp < len(cps) - 1:
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.isLoading = true
            eventPlayer.teleport(eventPlayer.cpData[0])
            eventPlayer.applyImpulse(eventPlayer.getVelocity() * -0.001, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
            eventPlayer.isLoading = false
        playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, null, eventPlayer, 100)
    else:
        finalCpReached()
    eventPlayer.isLoading = false


def finalCpReached():
    @Name "21.1: Final Checkpoint Reached"
    
    playEffect(eventPlayer, DynamicEffect.BAD_PICKUP_EFFECT, Color.GREEN, eventPlayer, 200)
    playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer, 100)
    if eventPlayer.spectating[0]:
        return
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if eventPlayer.isRunLegit:
            if settings_[1]:
                updateStats()
    if not eventPlayer.isRunFinished:
        eventPlayer.isRunFinished = true
        eventPlayer.runFinalTimeFormatted = eventPlayer.runTimeFormatted
        eventPlayer.runFinalMistakes = eventPlayer.runMistakes
        eventPlayer.isViewingRunCompletionText = true
    eventPlayer.isInFreemode = true
    eventPlayer.nameplate = "{} | FREEMODE".format(eventPlayer)


rule "21.2.1: Load Run Completion Text":
    @Event eachPlayer
    @Condition eventPlayer.isViewingRunCompletionText == true

    wait(30)
    eventPlayer.isViewingRunCompletionText = false


rule "21.2.2: Run Completion Text":
    hudSubheader(getAllPlayers().filter(lambda localPlayer: localPlayer.isViewingRunCompletionText), "\n\nCongrats, {}!\n".format(localPlayer), HudPosition.TOP, 2, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)    
    hudSubheader(getAllPlayers().filter(lambda localPlayer: localPlayer.isViewingRunCompletionText), "Time: {}".format(localPlayer.runFinalTimeFormatted), HudPosition.TOP, 3, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda localPlayer: localPlayer.isViewingRunCompletionText), "Time to Beat: {}".format("00:00.00" if timeToBeatInMs == 0 else
            "{}:{}:{}".format(
                floor(timeToBeatInMs / 3600000),
                (timeToBeatInMs % 3600000 / 60000 + 100).substring(1, 2),
                (timeToBeatInMs % 60000 / 1000 + 100).substring(1, 9999)
            ) if timeToBeatInMs >= 3600000 else
            "{}:{}".format(
                floor(timeToBeatInMs / 60000),
                (timeToBeatInMs % 60000 / 1000 + 100).substring(1, 9999)
            ) if timeToBeatInMs >= 60000 else
            "{}.{}".format(
                floor(timeToBeatInMs / 1000),
                (timeToBeatInMs % 1000 / 10 + 100).substring(1, 2)
            )
        ), HudPosition.TOP, 4, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(getAllPlayers().filter(lambda localPlayer: localPlayer.isViewingRunCompletionText), "Mistakes: {}\n".format(localPlayer.runFinalMistakes), HudPosition.TOP, 5, rgb(230, 151, 0), HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda localPlayer: localPlayer.isViewingRunCompletionText), 
        "                Top-10 Time!</fg>\n"
        "<fgEC2300FF>Submit a Video of Your Run\n"
        "                        @\n"
        "              ballkour.com</fg>\n\n"
        "       <fg00E697FF>Thanks for Playing!</fg>"
    , HudPosition.TOP, 6, rgb(230, 151, 0), HudReeval.VISIBILITY)

        
def updateStats():
    @Name "21.2: Update Lobby Stats With New Run"
    
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


rule "22.1.1: Controls HUD Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.spectating[6] == false
    @Condition eventPlayer.isInLobby == false
    
    eventPlayer.isViewingCtrlsHud = true
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE) or eventPlayer.isInLobby, Math.INFINITY)
    eventPlayer.isViewingCtrlsHud = false
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.ABILITY_1)
    eventPlayer.allowButton(Button.ABILITY_2)


rule "22.1.2: Load Controls HUD":
    hudSubheader(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isViewingCtrlsHud and localPlayer.runCurrentCp != 0), 
        ("Prev CP:                             {} + {}").format(inputBindingString(Button.ULTIMATE), inputBindingString(Button.SECONDARY_FIRE)), HudPosition.LEFT, 1, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isViewingCtrlsHud and localPlayer.runCurrentCp < len(cps) - 1), 
            (
                "Next CP:                            {} + {}\n"
                "Reset CP:                         {} (Hold)"
            ).format(
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.SECONDARY_FIRE),
                inputBindingString(Button.RELOAD)
            ), HudPosition.LEFT, 2, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isViewingCtrlsHud), 
        ("New Run:               {} + {} (Hold)").format(inputBindingString(Button.ULTIMATE), inputBindingString(Button.RELOAD)), HudPosition.LEFT, 3, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isViewingCtrlsHud and localPlayer.runCurrentCp < len(cps) - 1 and not localPlayer.spectating[0]), 
        ("Freemode:                          {} + {}").format(inputBindingString(Button.ULTIMATE), inputBindingString(Button.INTERACT)), HudPosition.LEFT, 4, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isViewingCtrlsHud), 
            (
                "Spectate:                     {} + {}\n"
                "Lobby/Pause:                      {} + {}"
            ).format(
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.ABILITY_1),
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.ABILITY_2)
            ), HudPosition.LEFT, 5, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isViewingCtrlsHud and localPlayer.spectating[0]),
        (
            "<fgEC9900FF>- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -</fg>\n"
            "<fgEC9900FF>            Spectator Controls</fg>\n"
            "Disable:                        {} + {}"
        ).format(
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.ABILITY_1)
        ), HudPosition.LEFT, 6, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isViewingCtrlsHud and localPlayer.spectating[0] and localPlayer.spectating[8]),
        (
            "Prev Player:             {} + {}\n"
            "Next Player:             {} + {}\n"
            "X-Hair Player:    {} + {}"
        ).format(
            inputBindingString(Button.ABILITY_1), inputBindingString(Button.PRIMARY_FIRE),
            inputBindingString(Button.ABILITY_1), inputBindingString(Button.SECONDARY_FIRE),
            inputBindingString(Button.ABILITY_1), inputBindingString(Button.JUMP)
        ), HudPosition.LEFT, 7, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isViewingCtrlsHud and localPlayer.spectating[0] and not localPlayer.spectating[2]),
        (
            "First Person:              {} + {}\n"
            "Freecam:                             Move"
        ).format(inputBindingString(Button.ABILITY_1), inputBindingString(Button.INTERACT)), HudPosition.LEFT, 8, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.isViewingCtrlsHud and localPlayer.spectating[0] and localPlayer.spectating[1] != null and localPlayer.spectating[2]),
        ("Reattach:                     {} + {}").format(inputBindingString(Button.ABILITY_1), inputBindingString(Button.RELOAD)), HudPosition.LEFT, 9, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)


rule "22.2: Prev. Checkpoint Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[6] == false
    @Condition ((eventPlayer.runCurrentCp > 0 and not eventPlayer.spectating[0]) or (eventPlayer.spectating[3] > 0 and eventPlayer.spectating[0])) == true
    @Condition eventPlayer.isInLobby == false
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.isLoading = true
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    if not eventPlayer.spectating[0]:
        eventPlayer.runCurrentCp--
        eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
    else:
        eventPlayer.spectating[3]--
        eventPlayer.spectating[2] = true
        eventPlayer.spectating[4] = true
    loadCpData()
    cpResetPlayer()
    setCpAbilities()
    if not eventPlayer.spectating[0]:
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[7]), Relativity.TO_WORLD)
    else:
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), cps[eventPlayer.spectating[3]][7]), Relativity.TO_WORLD)
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE) or not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE), 0.25)
    if eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and ((eventPlayer.runCurrentCp > 0 and not eventPlayer.spectating[0]) or (eventPlayer.spectating[3] > 0 and eventPlayer.spectating[0])):
        eventPlayer.isLoading = true
        while eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and ((eventPlayer.runCurrentCp > 0 and not eventPlayer.spectating[0]) or (eventPlayer.spectating[3] > 0 and eventPlayer.spectating[0])):
            if not eventPlayer.spectating[0]:
                eventPlayer.runCurrentCp--
                eventPlayer.teleport(cps[eventPlayer.runCurrentCp][0])
                eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
            else:
                eventPlayer.spectating[3]--
                eventPlayer.teleport(cps[eventPlayer.spectating[3]][0])
            wait(0.02)
        loadCpData()
        cpResetPlayer()
        if not eventPlayer.spectating[0]:
            eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[7]), Relativity.TO_WORLD)
        else:
            eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), cps[eventPlayer.spectating[3]][7]), Relativity.TO_WORLD)
    eventPlayer.setPrimaryFireEnabled(true)


rule "22.3: Next Checkpoint Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[6] == false
    @Condition ((eventPlayer.runCurrentCp < len(cps) - 1 and not eventPlayer.spectating[0]) or (eventPlayer.spectating[3] < len(cps) - 1 and eventPlayer.spectating[0])) == true
    @Condition eventPlayer.isInLobby == false
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.isLoading = true    
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    if not eventPlayer.spectating[0]:
        eventPlayer.isRunLegit = false
        eventPlayer.runCurrentCp++
        eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
    else:
        eventPlayer.spectating[3]++
        eventPlayer.spectating[2] = true
        eventPlayer.spectating[4] = true
    loadCpData()
    cpResetPlayer()
    setCpAbilities()
    if not eventPlayer.spectating[0]:
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[7]), Relativity.TO_WORLD)
    else:
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), cps[eventPlayer.spectating[3]][7]), Relativity.TO_WORLD)
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE) or not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE), 0.25)
    if eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and ((eventPlayer.runCurrentCp < len(cps) - 1 and not eventPlayer.spectating[0]) or (eventPlayer.spectating[3] < len(cps) - 1 and eventPlayer.spectating[0])):
        eventPlayer.isLoading = true
        while eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and ((eventPlayer.runCurrentCp < len(cps) - 1 and not eventPlayer.spectating[0]) or (eventPlayer.spectating[3] < len(cps) - 1 and eventPlayer.spectating[0])):
            if not eventPlayer.spectating[0]:
                eventPlayer.runCurrentCp++
                eventPlayer.teleport(cps[eventPlayer.runCurrentCp][0])
                eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
            else:
                eventPlayer.spectating[3]++
                eventPlayer.teleport(cps[eventPlayer.spectating[3]][0])
            wait(0.02)
        loadCpData()
        cpResetPlayer()
        if not eventPlayer.spectating[0]:
            eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[7]), Relativity.TO_WORLD)
        else:
            eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), cps[eventPlayer.spectating[3]][7]), Relativity.TO_WORLD)
    if eventPlayer.runCurrentCp == len(cps) - 1:
        finalCpReached()


rule "22.4: Reset Checkpoint Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.spectating[6] == false
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    @Condition eventPlayer.isInLobby == false
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    
    waitUntil(not eventPlayer.isHoldingButton(Button.RELOAD), 0.2)
    if not eventPlayer.isHoldingButton(Button.RELOAD) and eventPlayer.runCurrentCp < len(cps) - 1:
        return
    if not eventPlayer.isRunPaused:
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    eventPlayer.isLoading = true
    cpResetPlayer()


rule "22.5: New Run Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.isInLobby == false
    
    waitUntil(not (eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.RELOAD)), 0.35)
    if not (eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.RELOAD)) and eventPlayer.runCurrentCp < len(cps) - 1:
        return
    eventPlayer.isLoading = true
    stopChasingVariable(eventPlayer.runTime)
    eventPlayer.isViewingRunCompletionText = false
    newRun()
    eventPlayer.isLoading = false


rule "22.6.1: Freemode Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[0] == false
    @Condition eventPlayer.spectating[6] == false
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    
    eventPlayer.disallowButton(Button.MELEE)
    if not eventPlayer.isInFreemode:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if not eventPlayer.spectating[0]:
            eventPlayer.isRunLegit = false
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.setAbility2Enabled(true)
        eventPlayer.allowButton(Button.CROUCH)
        eventPlayer.nameplate = "{} | FREEMODE".format(eventPlayer)
        eventPlayer.isInFreemode = true
    else:
        eventPlayer.isLoading = true
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            cpResetPlayer()
        eventPlayer.setSecondaryFireEnabled(eventPlayer.cpData[2])
        eventPlayer.setAbility2Enabled(eventPlayer.cpData[3])
        if not eventPlayer.cpData[4]:
            eventPlayer.disallowButton(Button.CROUCH)
        else:
            eventPlayer.allowButton(Button.CROUCH)
        eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
        eventPlayer.isInFreemode = false
        eventPlayer.isLoading = false
    eventPlayer.allowButton(Button.MELEE)


rule "22.6.2: Load Freemode HUD":
    hudSubtext(getAllPlayers().filter(lambda localPlayer: localPlayer.isInFreemode and not localPlayer.spectating[0]), 
    ("\n\n\nFreemode On"), HudPosition.LEFT, 10, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)


rule "22.7.1.1: Spectator Mode Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[6] == false
    @Condition eventPlayer.isInLobby == false

    # spectating[i]: [0]isSpectating [1]whoPlayerIsSpectating [2]isInFreecam [3]freecamCp [4]isInDetachedFreecam [5]playerPosition [6]isInFirstPersonSpectate [7]hasSpectatingTarget [8]hasSpectatableTargets [9]xhairTarget
    if not eventPlayer.spectating[0]:
        eventPlayer.spectating[0] = true
    else:
        disableSpectatorMode()
        

rule "22.7.1.2: Load Spectate HUD":
    hudSubtext(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[0] and (localPlayer.spectating[1] != null and not localPlayer.spectating[4])), 
        ("\n\nSpectating {}").format(localPlayer.spectating[1]), HudPosition.LEFT, 10, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers()
        .filter(lambda localPlayer: (localPlayer.spectating[0] and localPlayer.spectating[1] == null) or (localPlayer.spectating[2] and localPlayer.spectating[4])), 
        ("\n\nFreecam On").format(localPlayer.spectating[1]), HudPosition.LEFT, 11, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers()
        .filter(lambda localPlayer: localPlayer.spectating[2] and not localPlayer.spectating[4]), 
        ("Freecam On").format(localPlayer.spectating[1]), HudPosition.LEFT, 11, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers()
        .filter(lambda localPlayer: (localPlayer.spectating[0] and localPlayer.spectating[1] == null) or (localPlayer.spectating[2] and localPlayer.spectating[4])), 
        ("(Detached)").format(localPlayer.spectating[1]), HudPosition.LEFT, 12, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)


rule "22.7.2.1: Enable Spectator Mode":
    @Event eachPlayer
    @Condition eventPlayer.spectating[0] == true
    
    eventPlayer.isViewingRunCompletionText = false
    eventPlayer.spectating[5] = eventPlayer.getPosition()
    stopChasingVariable(eventPlayer.runTime)
    eventPlayer.isRunPaused = true
    if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
        eventPlayer.runMistakes++
    if (len(getAllPlayers())) == 1:
        eventPlayer.spectating[4] = true
        eventPlayer.nameplate = "{} | FREECAM".format(eventPlayer)
        return
    if len(getAllPlayers().filter(lambda p: p != eventPlayer and p == eventPlayer.spectating[1])) == 0:
        eventPlayer.spectating[1] = getAllPlayers()[(getAllPlayers().index(eventPlayer) - 1 + len(getAllPlayers())) % len(getAllPlayers())]
    eventPlayer.startCamera(eventPlayer.spectating[1].getEyePosition() - eventPlayer.spectating[1].getFacingDirection() * 2 + vect(0, 0.5, 0), eventPlayer.spectating[1].getEyePosition() + eventPlayer.spectating[1].getFacingDirection(), 500)
    eventPlayer.startForcingPosition(eventPlayer.spectating[1].getPosition())
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.disallowButton(Button.CROUCH)
    eventPlayer.nameplate = ""
    enableFreecamForAffectedSpecs()
    eventPlayer.spectating[7] = true


rule "22.7.2.3: Spectating Camera Loop":
    @Event eachPlayer
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[2] == false
    @Condition eventPlayer.spectating[1] != null
    @Condition eventPlayer.spectating[6] == false

    while eventPlayer.spectating[0] and not eventPlayer.spectating[2] and eventPlayer.spectating[1] != null and not eventPlayer.spectating[6]:
        eventPlayer.startForcingPosition(eventPlayer.spectating[1].getPosition())
        eventPlayer.startCamera(eventPlayer.spectating[1].getEyePosition() - eventPlayer.spectating[1].getFacingDirection() * 2 + vect(0, 0.5, 0), eventPlayer.spectating[1].getEyePosition() + eventPlayer.spectating[1].getFacingDirection(), 500)
        wait()


def disableSpectatorMode():
    @Name "22.7.2.2: Disable Spectator Mode"
    
    eventPlayer.spectating[0] = false
    eventPlayer.spectating[2] = false
    eventPlayer.spectating[4] = false
    eventPlayer.enableEnvironmentCollision()
    eventPlayer.setMoveSpeed(100)
    eventPlayer.stopForcingPosition()
    eventPlayer.stopCamera()
    eventPlayer.setInvisibility(Invis.NONE)
    eventPlayer.startForcingHero(Hero.WRECKING_BALL)
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.CROUCH)
    eventPlayer.allowButton(Button.ABILITY_1)
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.allowButton(Button.ABILITY_2)
    if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
        if not eventPlayer.isInFreemode:
            cpResetPlayer()
            eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
        else:
            eventPlayer.teleport(eventPlayer.spectating[5])
            eventPlayer.nameplate = "{} | FREEMODE".format(eventPlayer)
    

rule "22.7.3: Track If Anyone Is Spectatable":
    @Event eachPlayer
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[8] != (len(getAllPlayers().filter(lambda p: p != eventPlayer and not p.spectating[0])) > 0)

    eventPlayer.spectating[8] = not eventPlayer.spectating[8]


rule "22.7.4: Spectate Prev. Player Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[6] == false
    @Condition len(getAllPlayers().filter(lambda p: p != eventPlayer and (not p.spectating[0] or p == eventPlayer.spectating[1]))) > 0

    if eventPlayer.spectating[2]:
        eventPlayer.startForcingHero(Hero.WRECKING_BALL)
        eventPlayer.setInvisibility(Invis.ALL)
        eventPlayer.disallowButton(Button.PRIMARY_FIRE)
        eventPlayer.disallowButton(Button.SECONDARY_FIRE)
        eventPlayer.disallowButton(Button.CROUCH)
        eventPlayer.disallowButton(Button.ABILITY_1)
        eventPlayer.disallowButton(Button.ABILITY_2)
        eventPlayer.startForcingPosition(eventPlayer.spectating[1].getPosition())
        eventPlayer.spectating[2] = false
        eventPlayer.spectating[4] = false
    # needed or else this triggers twice from hero change
    else:
        eventPlayer.spectating[1] = getAllPlayers().filter(lambda p: p != eventPlayer)[
            (getAllPlayers().filter(lambda p: p != eventPlayer).index(eventPlayer.spectating[1])
                + 1)
            % len(getAllPlayers().filter(lambda p: p != eventPlayer))]
    eventPlayer.startCamera(eventPlayer.spectating[1].getEyePosition() - eventPlayer.spectating[1].getFacingDirection() * 2 + vect(0, 0.5, 0), eventPlayer.spectating[1].getEyePosition() + eventPlayer.spectating[1].getFacingDirection(), 200)


rule "22.7.5: Spectate Next Player Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[6] == false
    @Condition len(getAllPlayers().filter(lambda p: p != eventPlayer and (not p.spectating[0] or p == eventPlayer.spectating[1]))) > 0

    if eventPlayer.spectating[2]:
        eventPlayer.startForcingPosition(eventPlayer.spectating[1].getPosition())
        eventPlayer.startForcingHero(Hero.WRECKING_BALL)
        eventPlayer.setInvisibility(Invis.ALL)
        eventPlayer.disallowButton(Button.PRIMARY_FIRE)
        eventPlayer.disallowButton(Button.SECONDARY_FIRE)
        eventPlayer.disallowButton(Button.CROUCH)
        eventPlayer.disallowButton(Button.ABILITY_1)
        eventPlayer.disallowButton(Button.ABILITY_2)
        eventPlayer.spectating[2] = false
        eventPlayer.spectating[4] = false
    else:
        eventPlayer.spectating[1] = getAllPlayers().filter(lambda p: p != eventPlayer)[
            (getAllPlayers().filter(lambda p: p != eventPlayer).index(eventPlayer.spectating[1])
                + len(getAllPlayers().filter(lambda p: p != eventPlayer)) - 1)
            % len(getAllPlayers().filter(lambda p: p != eventPlayer))]
    eventPlayer.startCamera(eventPlayer.spectating[1].getEyePosition() - eventPlayer.spectating[1].getFacingDirection() * 2 + vect(0, 0.5, 0), eventPlayer.spectating[1].getEyePosition() + eventPlayer.spectating[1].getFacingDirection(), 200)


rule "22.7.6: Spectate Crosshair (X-Hair) Player Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[6] == false
    @Condition len(getAllPlayers().filter(lambda p: p != eventPlayer and (not p.spectating[0] or p == eventPlayer.spectating[1]))) > 0
    
    eventPlayer.startCamera(eventPlayer.spectating[1].getEyePosition() - eventPlayer.spectating[1].getFacingDirection() * 2 + vect(0, 0.5, 0), eventPlayer.spectating[1].getEyePosition() + eventPlayer.spectating[1].getFacingDirection(), 200)
    if eventPlayer.spectating[2]:
        eventPlayer.spectating[9] = getAllPlayers().filter(lambda p: p != eventPlayer and not p.spectating[0] and angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), p.getEyePosition())) < 20)[0]
        if eventPlayer.spectating[9] == null:
            return
        eventPlayer.spectating[1] = eventPlayer.spectating[9]
        eventPlayer.startForcingPosition(eventPlayer.spectating[1].getPosition())
        eventPlayer.startForcingHero(Hero.WRECKING_BALL)
        eventPlayer.setInvisibility(Invis.ALL)
        eventPlayer.disallowButton(Button.PRIMARY_FIRE)
        eventPlayer.disallowButton(Button.SECONDARY_FIRE)
        eventPlayer.disallowButton(Button.CROUCH)
        eventPlayer.disallowButton(Button.ABILITY_1)
        eventPlayer.disallowButton(Button.ABILITY_2)
        eventPlayer.spectating[2] = false
        eventPlayer.spectating[4] = false
    

rule "22.7.7.1: Freecam Input":
    @Event eachPlayer
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[2] == false
    @Condition magnitude(eventPlayer.getThrottle()) > 0
    @Condition eventPlayer.spectating[6] == false

    eventPlayer.spectating[2] = true
    

rule "22.7.7.2: Freecam Enabled":
    @Event eachPlayer
    @Condition eventPlayer.spectating[2] == true

    eventPlayer.stopCamera()
    eventPlayer.stopForcingPosition()
    eventPlayer.startForcingHero(Hero.JETPACK_CAT)
    eventPlayer.setInvisibility(Invis.NONE)
    eventPlayer.disableEnvironmentCollision(true)
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.CROUCH)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.nameplate = "{} | FREECAM".format(eventPlayer)


rule "22.7.7.3: Freecam Detached Input":
    @Event eachPlayer
    @Condition eventPlayer.spectating[4] == true

    eventPlayer.spectating[2] = true


rule "22.7.7.4: Freecam Speed Boost":
    @Event eachPlayer
    @Condition eventPlayer.spectating[2] == true
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.getHero() == Hero.JETPACK_CAT

    eventPlayer.setMoveSpeed(300)


rule "22.7.7.5: Freecam Boost Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[2] == true
    @Condition eventPlayer.spectating[0] == true

    eventPlayer.setMoveSpeed(400)
    waitUntil(not eventPlayer.isFiringSecondaryFire(), Math.INFINITY)
    eventPlayer.setMoveSpeed(300)


rule "22.7.7.6: Freecam Environment Death":
    @Event playerDied
    @Condition eventPlayer.getHero() == Hero.JETPACK_CAT
    
    
    eventPlayer.resurrect()
    eventPlayer.teleport(nearestWalkablePosition(eventPlayer.getPosition()))
    if not eventPlayer.spectating[4]:
        reattachToSpectatingTarget()


def enableFreecamForAffectedSpecs():
    @Name "22.7.7.7: Enable Freecam for Players Spectating a Leaver or Someone Who Enables Spectator Mode"

    for index in range(len(getAllPlayers())):
        if getAllPlayers()[index].spectating[1] == eventPlayer:
            if getAllPlayers()[index].spectating[0] == true:
                getAllPlayers()[index].stopCamera()
                getAllPlayers()[index].stopForcingPosition()
                getAllPlayers()[index].spectating[4] = true
            getAllPlayers()[index].spectating[1] = null
            getAllPlayers()[index].spectating[7] = false


rule "22.7.8.1: Reattach Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[2] == true
    @Condition eventPlayer.spectating[6] == false
    @Condition eventPlayer.spectating[1] != null
    @Condition eventPlayer.spectating[7] == true

    reattachToSpectatingTarget()


def reattachToSpectatingTarget():
    @Name "22.7.8.2: Reattach"
    
    eventPlayer.startCamera(eventPlayer.spectating[1].getEyePosition() - eventPlayer.spectating[1].getFacingDirection() * 2 + vect(0, 0.5, 0), eventPlayer.spectating[1].getEyePosition() + eventPlayer.spectating[1].getFacingDirection(), 200)
    eventPlayer.startForcingPosition(eventPlayer.spectating[1].getPosition())
    eventPlayer.startForcingHero(Hero.WRECKING_BALL)
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.applyImpulse(eventPlayer.getVelocity() * -0.001, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.CROUCH)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.spectating[2] = false
    eventPlayer.spectating[4] = false


rule "22.7.9.1: First Person Spectate Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[2] == false
    @Condition eventPlayer.spectating[0] == true

    eventPlayer.spectating[6] = not eventPlayer.spectating[6]

rule "22.7.9.2: Enable First Person Spectate":
    @Event eachPlayer
    @Condition eventPlayer.spectating[6] == true

    bigMessage(
        eventPlayer,
        (
            "!!HEADS UP!!\n"
            "Hold a non-movement button to exit!\n"
            "- - - - - - - - - - - - - - - - - - - - -\n"
            "Press Space to change perspective"
        )
    )
    eventPlayer.setRespawnTime(Math.INFINITY)
    kill(eventPlayer)
    eventPlayer.enableDeathSpectateTargetHud()
    eventPlayer.startCamera(eventPlayer.spectating[1].getEyePosition() - eventPlayer.spectating[1].getFacingDirection() * 2 + vect(0, 0.5, 0), eventPlayer.spectating[1].getEyePosition() + eventPlayer.spectating[1].getFacingDirection(), 200)
    eventPlayer.spectating[2] = false
    eventPlayer.spectating[4] = false
    waitUntil(
        not eventPlayer.isHoldingButton(Button.ULTIMATE) and
        not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and
        not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and
        not eventPlayer.isHoldingButton(Button.RELOAD) and
        not eventPlayer.isHoldingButton(Button.INTERACT) and
        not eventPlayer.isHoldingButton(Button.CROUCH) and
        not eventPlayer.isHoldingButton(Button.ABILITY_1) and
        not eventPlayer.isHoldingButton(Button.ABILITY_2) and
        not eventPlayer.isCommunicatingAnything(),
        1
    )
    wait(3, Wait.RESTART_WHEN_TRUE)
    if eventPlayer.spectating[6] == false:
        return
    bigMessage(
        eventPlayer,
        (
            "!!HEADS UP!!\n"
            "Hold a non-movement button to exit!\n"
            "- - - - - - - - - - - - - - - - -\n"
            "Press Space to change perspective"
        )
    )
    wait(3, Wait.RESTART_WHEN_TRUE)
    if eventPlayer.spectating[6] == false:
        return
    bigMessage(
        eventPlayer,
        (
            "!!HEADS UP!!\n"
            "Hold a non-movement button to exit!\n"
            "- - - - - - - - - - - - - - - - -\n"
            "Press Space to change perspective"
        )
    )
    if eventPlayer.spectating[6] == false:
        return
    wait(4, Wait.RESTART_WHEN_TRUE)
    eventPlayer.stopCamera()


rule "22.7.10: Exit First Person Spectate Input":
    @Event eachPlayer
    @Condition (
        eventPlayer.isHoldingButton(Button.ULTIMATE) or 
        eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or
        eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or
        eventPlayer.isHoldingButton(Button.RELOAD) or
        eventPlayer.isHoldingButton(Button.INTERACT) or
        eventPlayer.isHoldingButton(Button.CROUCH) or
        eventPlayer.isHoldingButton(Button.ABILITY_1) or
        eventPlayer.isHoldingButton(Button.ABILITY_2) or 
        eventPlayer.isCommunicatingAnything()
    ) == true
    @Condition eventPlayer.spectating[6] == true
    @Condition eventPlayer.spectating[0] == true

    waitUntil(
        not eventPlayer.isHoldingButton(Button.ULTIMATE) and
        not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and
        not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and
        not eventPlayer.isHoldingButton(Button.RELOAD) and
        not eventPlayer.isHoldingButton(Button.INTERACT) and
        not eventPlayer.isHoldingButton(Button.CROUCH) and
        not eventPlayer.isHoldingButton(Button.ABILITY_1) and
        not eventPlayer.isHoldingButton(Button.ABILITY_2) and
        not eventPlayer.isCommunicatingAnything(),
        0.25
    )
    if (
        eventPlayer.isHoldingButton(Button.ULTIMATE) or 
        eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or
        eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or
        eventPlayer.isHoldingButton(Button.RELOAD) or
        eventPlayer.isHoldingButton(Button.INTERACT) or
        eventPlayer.isHoldingButton(Button.CROUCH) or
        eventPlayer.isHoldingButton(Button.ABILITY_1) or
        eventPlayer.isHoldingButton(Button.ABILITY_2) or 
        eventPlayer.isCommunicatingAnything()
    ) == true:
        eventPlayer.resurrect()
        eventPlayer.disableDeathSpectateTargetHud()
        eventPlayer.startCamera(eventPlayer.spectating[1].getEyePosition() - eventPlayer.spectating[1].getFacingDirection() * 2 + vect(0, 0.5, 0), eventPlayer.spectating[1].getEyePosition() + eventPlayer.spectating[1].getFacingDirection(), 200)
        eventPlayer.spectating[6] = false


rule "22.8: Lobby Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.spectating[6] == false
    @Condition eventPlayer.isInLobby == false
    
    eventPlayer.isLoading = true
    if eventPlayer.spectating[0]:
        disableSpectatorMode()
    eventPlayer.setAbility2Enabled(false)
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    eventPlayer.isViewingRunCompletionText = false
    loadLobby()
    eventPlayer.isLoading = false


rule "23: Auto-Restart Server":
    @SuppressWarnings w_ow2_rule_condition_chase
    # 3hr29min in
    @Condition elapsedTime >= 12540
    
    chaseAtRate(elapsedTime, Math.INFINITY, 1)
    bigMessage(true[0], "Server restart: \n30min")
    wait(900)
    bigMessage(true[0], "Server restart: \n15min")
    wait(600)
    bigMessage(true[0], "Server restart: \n5min")
    wait(240)
    bigMessage(true[0], "Server restart: \n1min")
    wait(60)
    # 3hr59min in
    restartMatch()
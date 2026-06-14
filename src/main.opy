#!setupTags

rule "6.1: Initialize Match":
    disableAnnouncer()
    disableGamemodeCompletion()
    setMatchTime(0)
    if not settings_[0]:
        disableInspector()
    if settings_[1]:
        players = []
        #lobbyStats[i]: [0]players [1]rejoins [2]legitRuns [3]totalRunTime [4]totalRunTimeFormatted [5]totalMistakes [6]avgRunTime [7]avgRunTimeFormatted [8]avgMistakes
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

rule "6.2: Start Elapsed Timer":
    chaseAtRate(elapsedTime, 14340, 1)
    if settings_[1] and not settings_[0]:
        while true:
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
    eventPlayer.disablePlayerCollision()
    eventPlayer.disableNameplatesFor(getAllPlayers())
    getAllPlayers().disableNameplatesFor(eventPlayer)
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer != eventPlayer), eventPlayer.nameplate, eventPlayer, 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING)
    wait()
    loadLobby()
    wait(0.1)
    eventPlayer.isLoading = false


rule "7.2: Player Leaves":
    @Event playerLeft
    @Condition eventPlayer.isDummy() == false
    
    if not eventPlayer.isRunPaused:
        playersUnpaused--


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


rule "8.2: Load Welcome Area":
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), "Welcome to", lobbyData[2], lobbyData[4], Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), "Ballkour!", lobbyData[3], lobbyData[4], Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ORANGE)


rule "8.3: Load Leaderboard Area":
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), "Leaderboard", lobbyData[11], lobbyData[12], Clip.SURFACES, WorldTextReeval.VISIBILITY, rgb(165, 42, 42))
    for index in range(1, 11):
        if lb[index] != null:
            formatLbString()
            createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), lbObjFormatted, lbPos[index], lobbyData[13], Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE)
        else:
            if lb[index] <= 9:
                createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), "<fgA52A2AFF>{}</fg>. <fgEC9900FF>---</fg>                                               <fgA52A2AFF>(</fg>{}<fgEC9900FF>-:--.--, {}-</fg><fgA52A2AFF>)</fg>".format(index, iconString(Icon.BOLT), iconString(Icon.SKULL)), lbPos[index], lobbyData[13], Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE)
            else:
                createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), "<fgA52A2AFF>10</fg>. <fgEC9900FF>---</fg>                                              <fgA52A2AFF>(</fg>{}<fgEC9900FF>-:--.--, {}-</fg><fgA52A2AFF>)</fg>".format(iconString(Icon.BOLT), iconString(Icon.SKULL)), lbPos[index], lobbyData[13], Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE)


def formatLbString():
    @Name "8.3.1: Format Leaderboard String"
    
    #lbObj[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator
    lbObj = lb[index].split(",")
    lbObj[3] = lbObj[3].replace("'", "")
    lbObjFormatted = "<fgA52A2AFF>{}</fg>. <fgEC9900FF>{}</fg>{}<fgA52A2AFF>(</fg>{}<fgEC9900FF>{}, {}{}</fg><fgA52A2AFF>)</fg>".format(index, lbObj[0], lbObj[3], iconString(Icon.BOLT), lbObj[1], iconString(Icon.SKULL), lbObj[2])


rule "8.4.1: Load Start Run Area":
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), "New Run", lobbyData[7], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.TURQUOISE)
    createEffect(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), Effect.RING, Color.SKY_BLUE, lobbyData[5], 1.6, EffectReeval.VISIBILITY)
    createIcon(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), lobbyData[6], Icon.FLAG, IconReeval.VISIBILITY, Color.GREEN, false)
    createEffect(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby), Effect.SPARKLES, Color.ORANGE, lobbyData[5] + vect(0, -0.85, 0), 1.6, EffectReeval.VISIBILITY)


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
    createEffect(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and localPlayer.isRunLoaded and not localPlayer.isRunFinished), Effect.SPARKLES, Color.ORANGE, lobbyData[8] + vect(0, -0.85, 0), 1.6, EffectReeval.VISIBILITY)


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
    
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), "Stats", lobbyData[14], lobbyData[15], Clip.SURFACES, WorldTextReeval.VISIBILITY, rgb(165, 42, 42))
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), "Elapsed Time: {}".format(elapsedTimeFormatted if not settings_[0] else elapsedTime), lobbyData[17], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), "New Players: {}".format(lobbyStats[0]), lobbyData[18], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), "Rejoins: {}".format(lobbyStats[1]), lobbyData[19], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), "Legit Runs: {}".format(lobbyStats[2]), lobbyData[20], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), "Total Run Time: {}".format(lobbyStats[4]), lobbyData[21], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), "Total Mistakes: {}".format(lobbyStats[5]), lobbyData[22], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), "Avg Run Time: {}".format(lobbyStats[7]), lobbyData[23], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)
    createInWorldText(getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby and "{}".format(localPlayer) == hostPlayerName), "Avg Mistakes: {}".format(lobbyStats[8]), lobbyData[24], lobbyData[16], Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE)


rule "9: Clear Unused Variables":
    lb = null
    lbPos = null
    lbObj = null
    lbObjFormatted = null


rule "10: Load Run HUD":
    hudSubtext(getAllPlayers(), "ballkour.com", HudPosition.TOP, 0, rgb(165, 42, 42), HudReeval.VISIBILITY)
    hudSubtext(getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby), "\n\n\n\nControls: {}".format(inputBindingString(Button.ULTIMATE)), HudPosition.LEFT, 0, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby), "{}/{}".format(localPlayer.runCurrentCp, len(cps) - 1), HudPosition.TOP, 1, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
    if not settings_[0]:
        hudSubtext(getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby), "\n\n\n\n{} {}\n".format(iconString(Icon.BOLT), localPlayer.runTimeFormatted), HudPosition.RIGHT, 1, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
    else:
        hudSubtext(getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby), "\n\n\n\n{} {}\n".format(iconString(Icon.BOLT), localPlayer.runTime), HudPosition.RIGHT, 1, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby), "{} {}".format(iconString(Icon.SKULL), localPlayer.runMistakes), HudPosition.RIGHT, 3, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)


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
    wait()
    cpResetPlayer()
    setCpAbilities()
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), cps[eventPlayer.runCurrentCp][7]), Relativity.TO_WORLD)


def loadCpData():
    @Name "12.1: Load Checkpoint Data"
    
    #eventPlayer.cpData[i]: [0]cpLocation [1]cpSize [2]isGrappleAllowed [3]isShieldBounceAllowed [4]isPiledriverAllowed [5]bounceLocation [6]bounceSize [7]nextCpLocation [8]nextCpSize [9]isJumping [10]hasJumped [11]hasBhopped [12]isGrappling [13]hasUsedGrapple [14]hasShieldBounced [15]isPiledriving [16]hasUsedBounceJump [17]deathLocation
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
    
    if eventPlayer.runCurrentCp < len(cps) - 1 and not eventPlayer.isInFreemode:
        eventPlayer.setSecondaryFireEnabled(eventPlayer.cpData[2])
        eventPlayer.setAbility2Enabled(eventPlayer.cpData[3])
        if not eventPlayer.cpData[4]:
            eventPlayer.disallowButton(Button.CROUCH)
        else:
            eventPlayer.allowButton(Button.CROUCH)
    else:
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.setAbility2Enabled(true)
        eventPlayer.allowButton(Button.CROUCH)


rule "13: Load Checkpoint Objects":
    createEffect(getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.runCurrentCp == len(cps) - 1), Effect.RING, Color.GREEN, localPlayer.cpData[0], localPlayer.cpData[1], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby and localPlayer.cpData[5] != null and not localPlayer.runCurrentCp == len(cps) - 1), Effect.RING, Color.ORANGE, localPlayer.cpData[5], localPlayer.cpData[6], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby and localPlayer.cpData[5] != null and not localPlayer.runCurrentCp == len(cps) - 1), localPlayer.cpData[5], Icon.ARROW_UP, IconReeval.VISIBILITY_AND_POSITION, Color.YELLOW, false)
    createEffect(getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.runCurrentCp == len(cps) - 1), Effect.RING, Color.SKY_BLUE, localPlayer.cpData[7], localPlayer.cpData[8], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.runCurrentCp == len(cps) - 1), localPlayer.cpData[7] - vect(0, 0.5, 0), Icon.FLAG, IconReeval.VISIBILITY_AND_POSITION, Color.GREEN)
    createEffect(getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby and not localPlayer.runCurrentCp == len(cps) - 1), Effect.LIGHT_SHAFT, rgb(72, 127, 163, 0), localPlayer.cpData[7], localPlayer.cpData[8], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


rule "14.1: Start/Resume Run":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isRunPaused == true
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    
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


rule "15.1: Start Checkpoint Time Timer":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    
    eventPlayer.isCpTimerActive = true
    chaseAtRate(eventPlayer.cpTime, 99999999, 1)


rule "15.2: Restart Checkpoint Time Timer":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isCpTimerActive == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
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
        waitUntil(eventPlayer.isOnGround(), 99999999)
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.cpData[11] = true


rule "16.2: Grapple Use":
    @Event eachPlayer
    @Condition eventPlayer.isFiringSecondaryFire() == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    
    if not (eventPlayer.isInLobby or eventPlayer.cpData[5] == null or eventPlayer.isInFreemode):
        eventPlayer.cpData[12] = true
        waitUntil(not eventPlayer.isFiringSecondaryFire() or eventPlayer.getSpeed() >= 15, 99999999)
        if eventPlayer.getSpeed() >= 15:
            waitUntil(not eventPlayer.isFiringSecondaryFire(), 8.5)
        eventPlayer.cpData[12] = false
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.cpData[13] = true
        waitUntil(not eventPlayer.isFiringSecondaryFire(), 99999999)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    elif not eventPlayer.isInLobby and not eventPlayer.isInFreemode:
        waitUntil(not eventPlayer.isFiringSecondaryFire(), 99999999)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    if (not eventPlayer.isInLobby and eventPlayer.cpData[5] != null and not eventPlayer.isInFreemode):
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.setSecondaryFireEnabled(false)
        else:
            eventPlayer.cpData[13] = false
        waitUntil(not eventPlayer.isFiringSecondaryFire(), 99999999)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    elif (eventPlayer.isInLobby or eventPlayer.isInFreemode):
        waitUntil(not eventPlayer.isFiringSecondaryFire(), 99999999)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)


rule "16.3: Shield Bounce Use":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0

    if not (eventPlayer.isInLobby or eventPlayer.isInFreemode):
        if (eventPlayer.cpData[3] and not eventPlayer.cpData[14]):
            eventPlayer.applyImpulse(vect(0, 15, 0), 010, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
            eventPlayer.applyImpulse(normalize(vect(eventPlayer.getVelocity().x, 0, eventPlayer.getVelocity().z)), eventPlayer.getSpeed() * 0.25, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
            eventPlayer.setHealth(575)
            eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
            eventPlayer.setAbility2Enabled(false)
            eventPlayer.cpData[14] = true
    else:
        eventPlayer.applyImpulse(vect(0, 10, 0), 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        eventPlayer.applyImpulse(normalize(vect(eventPlayer.getVelocity().x, 0, eventPlayer.getVelocity().z)), eventPlayer.getSpeed() * 0.25, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
        eventPlayer.setHealth(575)
        eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)


rule "16.4: Piledriving":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    
    eventPlayer.cpData[15] = true
    waitUntil(eventPlayer.isOnGround(), 99999999)
    eventPlayer.cpData[15] = false


rule "16.5: Reset Useless Jump/Grapple/Shield Bounce/Bhop":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition (eventPlayer.cpData[10] or eventPlayer.cpData[11] or eventPlayer.cpData[13] or eventPlayer.cpData[14]) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isOnGround() == true
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) <= eventPlayer.cpData[1]
    
    if eventPlayer.cpData[2]:
        eventPlayer.cpData[13] = false
        eventPlayer.setSecondaryFireEnabled(true)
    if eventPlayer.cpData[3]:
        eventPlayer.cpData[14] = false
        eventPlayer.setAbility2Enabled(true)
        eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
    eventPlayer.cpData[10] = false
    eventPlayer.cpData[11] = false
    eventPlayer.cpData[16] = false


rule "17.1: Checkpoint Mistake: Missed Checkpoint":
    @Event eachPlayer
    @Condition eventPlayer.isInFreemode == false
    @Condition (eventPlayer.cpData[5] == null or (not eventPlayer.cpData[12] and not eventPlayer.cpData[13]) or (eventPlayer.cpData[16] and distance(vect(eventPlayer.getPosition().x, eventPlayer.cpData[5].y, eventPlayer.getPosition().z), eventPlayer.cpData[5]) > eventPlayer.cpData[6])) == true
    @Condition (eventPlayer.isOnGround() or eventPlayer.cpData[9] and eventPlayer.cpData[11]) == true
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isDummy() == false
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[7]) > eventPlayer.cpData[8]
    
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
    @Condition eventPlayer.cpData[11] == true
    @Condition eventPlayer.cpData[5] == null
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]
    @Condition distance(eventPlayer.getPosition(), eventPlayer.cpData[7]) > eventPlayer.cpData[8]
    
    eventPlayer.isLoading = true
    eventPlayer.runMistakes++
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "17.3: Checkpoint Mistake: Environment Death":
    @Event playerDied
    
    eventPlayer.isLoading = true
    if not eventPlayer.isInLobby:
        eventPlayer.cpData[17] = eventPlayer.getPosition()
        eventPlayer.respawn()
        if not eventPlayer.isInFreemode:
            cpResetPlayer()
            eventPlayer.runMistakes++
        else:
            eventPlayer.teleport(nearestWalkablePosition(eventPlayer.cpData[17]))
    else:
        eventPlayer.respawn()
        loadLobby()
    eventPlayer.isLoading = false


rule "18.1: Bounce Checkpoint Mistake: No Grapple":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.cpData[12] == false
    @Condition eventPlayer.cpData[13] == false
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
    @Condition distance(vect(eventPlayer.getPosition().x, eventPlayer.cpData[5].y, eventPlayer.getPosition().z), eventPlayer.cpData[5]) <= eventPlayer.cpData[6]
    
    eventPlayer.cpData[16] = true


rule "18.4: Bounce Checkpoint Mistake: Improperly Airborne":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading and not eventPlayer.isInLobby and not eventPlayer.hasStatus(Status.ROOTED)) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.cpData[16] == false
    @Condition eventPlayer.isJumping() == true
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
    eventPlayer.teleport(eventPlayer.cpData[0])
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
    
    playEffect(eventPlayer, DynamicEffect.BAD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 200)
    playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer, 100)
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
    hudSubheader(getAllPlayers().filter(lambda localPlayer: localPlayer.isViewingRunCompletionText), "Time: {}".format(localPlayer.runFinalTimeFormatted), HudPosition.TOP, 3, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
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
        ), HudPosition.TOP, 4, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(getAllPlayers().filter(lambda localPlayer: localPlayer.isViewingRunCompletionText), "Mistakes: {}\n".format(localPlayer.runFinalMistakes), HudPosition.TOP, 5, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda localPlayer: localPlayer.isViewingRunCompletionText), 
        "                <fgEC9900FF>Top-10 Time!</fg>\n"
        "<fgA52A2AFF>Submit a Video of Your Run\n"
        "                        @\n"
        "              ballkour.com</fg>\n\n"
        "       <fg00E697FF>Thanks for Playing!</fg>"
    , HudPosition.TOP, 6, Color.WHITE, HudReeval.VISIBILITY)

        
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
    @Condition eventPlayer.isInLobby == false
    
    eventPlayer.isViewingCtrlsHud = true
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ABILITY_2)
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE) or eventPlayer.isInLobby, 99999999)
    eventPlayer.isViewingCtrlsHud = false
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.ABILITY_2)


rule "22.1.2: Controls HUD":
    hudSubheader(getAllPlayers().filter(lambda localPlayer: localPlayer.isViewingCtrlsHud and localPlayer.runCurrentCp < len(cps) - 1), 
        (
            "Go Back CP:          {} + {}\n"
            "Skip CP:                   {} + {}\n"
            "Restart CP:        {} (Hold)\n"
            "Restart Run:           {} + {}\n"
            "Freemode:              {} + {}\n"
            "Lobby/Pause:         {} + {}"
        )
        .format(
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.PRIMARY_FIRE),
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.SECONDARY_FIRE), 
            inputBindingString(Button.RELOAD),
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.RELOAD),
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.INTERACT),
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.ABILITY_2)
        ), 
        HudPosition.LEFT, 1, rgb(165, 42, 42), HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(getAllPlayers().filter(lambda localPlayer: localPlayer.isViewingCtrlsHud and localPlayer.runCurrentCp == len(cps) - 1), 
        "Go Back CP:          {} + {}\n"
        "Restart Run:           {} + {}\n"
        "Lobby/Pause:         {} + {}"
        .format(
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.PRIMARY_FIRE),
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.RELOAD),
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.ABILITY_2)
        ), 
        HudPosition.LEFT, 1, rgb(165, 42, 42), HudReeval.VISIBILITY_AND_STRING
    )


rule "22.2: Go Back Checkpoint Input":
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
    
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.isLoading = true
    eventPlayer.isRunLegit = false
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    eventPlayer.runCurrentCp--
    eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
    loadCpData()
    cpResetPlayer()
    setCpAbilities()
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[7]), Relativity.TO_WORLD)
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE) or not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE), 0.25)
    if eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.runCurrentCp > 0:
        eventPlayer.isLoading = true
        while eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.runCurrentCp > 0:
            eventPlayer.runCurrentCp--
            eventPlayer.teleport(cps[eventPlayer.runCurrentCp][0])
            eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
            wait(0.02)
        loadCpData()
        cpResetPlayer()
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[7]), Relativity.TO_WORLD)
    eventPlayer.setPrimaryFireEnabled(true)


rule "22.3: Skip Checkpoint Input":
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
    
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.isLoading = true
    eventPlayer.isRunLegit = false
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    eventPlayer.runCurrentCp++
    eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
    loadCpData()
    cpResetPlayer()
    setCpAbilities()
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[7]), Relativity.TO_WORLD)
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE) or not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE), 0.25)
    if eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and eventPlayer.runCurrentCp < len(cps) - 1:
        eventPlayer.isLoading = true
        while eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and eventPlayer.runCurrentCp < len(cps) - 1:
            eventPlayer.runCurrentCp++
            eventPlayer.teleport(cps[eventPlayer.runCurrentCp][0])
            eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
            wait(0.02)
        loadCpData()
        cpResetPlayer()
        eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[7]), Relativity.TO_WORLD)
    if eventPlayer.runCurrentCp == len(cps) - 1:
        finalCpReached()
    eventPlayer.setSecondaryFireEnabled(true)


rule "22.4: Restart Checkpoint Input":
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
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    eventPlayer.isLoading = true
    cpResetPlayer()


rule "22.5: Restart Input":
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
    eventPlayer.isViewingRunCompletionText = false
    newRun()
    eventPlayer.isLoading = false


rule "22.6.1: Freemode Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.runCurrentCp < len(cps) - 1
    
    eventPlayer.disallowButton(Button.MELEE)
    if not eventPlayer.isInFreemode:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
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
    hudSubtext(getAllPlayers().filter(lambda localPlayer: localPlayer.isInFreemode and localPlayer.runCurrentCp < len(cps) - 1), 
    (
        "\n\n\n\n\n<fgEC9900FF>Freemode On</fg>"
        "\n<fgA52A2AFF>Disable: {} + {}</fg>"
    )
    .format(inputBindingString(Button.ULTIMATE), inputBindingString(Button.INTERACT)), HudPosition.LEFT, 11, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers().filter(lambda localPlayer: localPlayer.isInFreemode and localPlayer.runCurrentCp == len(cps) - 1), 
    (
        "\n\n\n\n\n<fgEC9900FF>Freemode On</fg>"
        "\n<fgA52A2AFF>Restart: {} + {}</fg>"
    )
    .format(inputBindingString(Button.ULTIMATE), inputBindingString(Button.RELOAD)), HudPosition.LEFT, 11, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "22.7: Lobby Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.isInLobby == false
    
    eventPlayer.isLoading = true
    eventPlayer.setAbility2Enabled(true)
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if distance(eventPlayer.getPosition(), eventPlayer.cpData[0]) > eventPlayer.cpData[1]:
            eventPlayer.runMistakes++
    eventPlayer.isViewingRunCompletionText = false
    loadLobby()
    eventPlayer.isLoading = false
    eventPlayer.setAbility2Enabled(false)


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
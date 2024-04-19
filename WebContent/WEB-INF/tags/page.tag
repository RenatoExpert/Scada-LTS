<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%--
    Mango - Open Source M2M - http://mango.serotoninsoftware.com
    Copyright (C) 2006-2011 Serotonin Software Technologies Inc.
    @author Matthew Lohbihler

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/.
--%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<%@include file="/WEB-INF/tags/decl.tagf"%>
<%@attribute name="styles" fragment="true" %>
<%@attribute name="dwr" %>
<%@attribute name="css" %>
<%@attribute name="js" %>
<%@attribute name="onload" %>
<%@attribute name="jqplugins" %>


<html>
<head>
  <title>
    <c:choose>
      <c:when test="${!empty instanceDescriptionHeader}">${instanceDescriptionHeader}</c:when>
      <c:otherwise><fmt:message key="header.title"/></c:otherwise>
    </c:choose>
  </title>

  <!-- Meta -->
  <meta http-equiv="content-type" content="application/xhtml+xml;charset=utf-8"/>
  <meta http-equiv="Content-Style-Type" content="text/css" />
  <meta name="Copyright" content="ScadaLTS &copy;${toYear}"/>
  <meta name="DESCRIPTION" content="ScadaLTS Software"/>
  <meta name="KEYWORDS" content="ScadaLTS Software"/>

  <!-- Style -->
  <link rel="icon" href="images/favicon.ico"/>
  <link rel="shortcut icon" href="images/favicon.ico"/>
  <link href="assets/layout.css" type="text/css" rel="stylesheet"/>

    <!-- Style Diego -->
    <link rel="stylesheet" href="assets/page.tag/page.tag.css"/>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Inter%3A400%2C500%2C600%2C700"/>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro%3A400%2C500%2C600%2C700"/>



  <c:set var="isRoles" value="${not empty sessionUser && sessionUser.getAttribute('roles') != null}" />
  <c:set var="isRolePublic" value="${isRoles && sessionUser.getAttribute('roles').contains('ROLE_PUBLIC')}" />
  <c:set var="isRoleService" value="${isRoles && (sessionUser.getAttribute('roles').size() == 1 && sessionUser.getAttribute('roles').contains('ROLE_SERVICES'))}" />
  <c:set var="isLoggedToScadaUser" value="${isRoles && !isRoleService && !isRolePublic}" />

  <c:choose>
    <c:when test="${isLoggedToScadaUser}">
      <link href="assets/common_${sessionUser.theme}.css" type="text/css" rel="stylesheet"/>
    </c:when>
    <c:otherwise>
      <link href="assets/common_DEFAULT.css" type="text/css" rel="stylesheet"/>
    </c:otherwise>
  </c:choose>

  <c:forTokens items="${css}" var="cssfile" delims=", ">
    <link href="resources/${cssfile}.css" type="text/css" rel="stylesheet"/>
  </c:forTokens>

  <link rel="stylesheet" type="text/css" href="assets/user_styles.css"/>
  <jsp:invoke fragment="styles"/>

  <style type="text/css">
    #__header__alarmLevelImg {
        height: 32px !important;
        width: 32px !important;
        vertical-align: middle !important;
    }
  </style>

  <!-- Scripts -->
  <script type="text/javascript">
  	var djConfig = { isDebug: false, extraLocale: ['en-us', 'nl', 'nl-nl', 'ja-jp', 'fi-fi', 'sv-se', 'zh-cn', 'zh-tw','xx'] };
  	var ctxPath = "<%=request.getContextPath()%>";
  </script>

  <!-- script type="text/javascript" src="http://o.aolcdn.com/dojo/0.4.2/dojo.js"></script -->

  <script type="text/javascript" src="resources/dojo/dojo.js"></script>
  <script type="text/javascript" src="resources/jQuery/jquery-1.10.2.min.js"></script>

  <c:forTokens items="${jqplugins}" var="plugin" delims=", ">
    <script type="text/javascript" src="resources/jQuery/plugins/${plugin}.js"></script>
  </c:forTokens>

  <script type="text/javascript">
      var jQuery = $;
      $ = null;
  </script>

  <script type="text/javascript" src="dwr/engine.js"></script>
  <script type="text/javascript" src="dwr/util.js"></script>
  <script type="text/javascript" src="dwr/interface/MiscDwr.js"></script>
  <script type="text/javascript" src="resources/soundmanager2-nodebug-jsmin.js"></script>
  <script type="text/javascript" src="resources/common.js"></script>

  <c:if test="${isLoggedToScadaUser}">
      <script src="resources/node_modules/stompjs/lib/stomp.min.js"></script>
      <script src="resources/node_modules/sockjs-client/dist/sockjs.min.js"></script>
  </c:if>

  <c:forEach items="${dwr}" var="dwrname">
    <script type="text/javascript" src="dwr/interface/${dwrname}.js"></script></c:forEach>

  <c:forTokens items="${js}" var="jsname" delims=", ">
    <script type="text/javascript" src="resources/${jsname}.js"></script></c:forTokens>

  <script type="text/javascript">
    mango.i18n = <sst:convert obj="${clientSideMessages}"/>;
  </script>

  <c:if test="${!simple}">
    <script type="text/javascript" src="resources/header.js"></script>
    <script type="text/javascript">

	    function loadjscssfile(filename, filetype){
			if (filetype=="js"){ //if filename is a external JavaScript file
	    		var fileref=document.createElement('script')
	    		fileref.setAttribute("type","text/javascript")
	    		fileref.setAttribute("src", filename)
			} else if (filetype=="css"){ //if filename is an external CSS file
	    		var fileref=document.createElement("link")
	    		fileref.setAttribute("rel", "stylesheet")
	    		fileref.setAttribute("type", "text/css")
	    		fileref.setAttribute("href", filename)
			}
			if (typeof fileref!="undefined")
	    		document.getElementsByTagName("head")[0].appendChild(fileref)
		};

      dwr.util.setEscapeHtml(false);

      <c:if test="${isLoggedToScadaUser || isRolePublic}">
        dojo.addOnLoad(mango.header.onLoad);
      </c:if>
      <c:if test="${isLoggedToScadaUser}">
        dojo.addOnLoad(function() { setUserMuted(${sessionUser.muted}); });
        <c:if test="${sessionUser.hideMenu}">
          dojo.addOnLoad(function() { setFullscreenIfGraphicView(); });
        </c:if>
        dojo.addOnLoad(function() { onloadHandler(); });
      </c:if>

      function setLocale(locale) {
          MiscDwr.setLocale(locale, function() { window.location = window.location });
      }

      function setHomeUrl() {
          MiscDwr.setHomeUrl(window.location.href, function() { alert("Home URL saved"); });
      }

      function goHomeUrl() {
          MiscDwr.getHomeUrl(function(loc) { window.location = loc; });
      }

      function setFullscreenIfGraphicView() {
        if(window.location.href.includes("views.shtm")) {
          document.cookie = "fullScreen=yes";
          checkFullScreen();
        }
      }

    <c:if test="${isLoggedToScadaUser}">
        var errorCallback = function(error) {
            alert("Connect error:" + error);
        }

        var stompClient = null;

        var maxAlarmLevel = -1;

        var connectCallback = function(frame) {
            //console.log('Connected: ' + frame);

            stompClient.subscribe("/app/alarmLevel/register", function(message) {
                //console.log("message[/app/alarmLevel/register]:" + message.body);
                stompClient.subscribe("/topic/alarmLevel/"+message.body, function(message) {
                    var response = JSON.parse(message.body);
                    var alarmLevel = parseInt(response.alarmlevel);
                    //console.log("response.alarmLevel: "+response.alarmlevel);
                    if (alarmLevel > 0) {
                        maxAlarmLevel = alarmLevel;
                        document.getElementById("__header__alarmLevelText").innerHTML = response.alarmlevel;
                        setAlarmLevelImg(alarmLevel, "__header__alarmLevelImg");
                        setAlarmLevelText(alarmLevel, "__header__alarmLevelText");
                        document.getElementById("__header__alarmLevelDiv").style.visibility='visible';
                        document.getElementById("__header__alarmLevelImg").style.visibility='visible';
                    }
                    else {
                        document.getElementById("__header__alarmLevelText").innerHTML = "";
                        document.getElementById("__header__alarmLevelImg").style.visibility='hidden';
                        document.getElementById("__header__alarmLevelDiv").style.visibility='hidden';
                    }
                })
                stompClient.send("/app/alarmLevel", {priority: 1}, "STOMP - gimme my alarmLevel");
            });

            stompClient.subscribe("/app/event/update/register", function(message) {
                stompClient.subscribe("/topic/event/update/"+message.body, function(message) {
                    var response = JSON.parse(message.body);
                    var alarmLevel = parseInt(response.alarmLevel);
                    if (alarmLevel > 0) {
                        if(!response.silenced && response.action == 'CREATE' && response.active) {
                            if(alarmLevel >= maxAlarmLevel) {
                                mango.soundPlayer.playOnce("level"+ alarmLevel);
                                if(!mango.header.evtVisualizer.started) {
                                    mango.header.evtVisualizer.start();
                                    setTimeout(function() {mango.header.evtVisualizer.stop()}, 5000);
                                }
                            }
                        }
                    }
                })
                stompClient.send("/app/event/update", {priority: 1}, "STOMP - gimme my event");
            });
        };

        function connect(url, headers, errorCallback, connectCallback) {
            var socket = new SockJS(url);
            var stompClient = Stomp.over(socket);
            stompClient.heartbeat.outgoing = 20000;
            stompClient.heartbeat.incoming = 0;
            stompClient.debug = null;
            stompClient.connect(headers, connectCallback, errorCallback);
            return stompClient;
        }

        function disconnect() {
            if(stompClient != null) {
                console.log("Disconnecting...");
                stompClient.disconnect(function() {
                    console.log("Disconnected");
                    stompClient = null;
                });
            }
        }

        function onloadHandler() {
           var location = window.location;
           var appName = location.pathname.split("/")[1];
           var myLocation = location.origin + "/" + appName+ "/";
           stompClient = connect(myLocation + 'ws-scada/alarmLevel', {}, errorCallback, connectCallback);
        }

        function setAlarmLevelText(alarmLevel, textNode) {
            textNode = document.getElementById(textNode);
            if (alarmLevel == 0)
                textNode.innerHTML = "";
            else if (alarmLevel == 1)
                textNode.innerHTML = '<fmt:message key="common.alarmLevel.info"/>';
            else if (alarmLevel == 2)
                textNode.innerHTML = '<fmt:message key="common.alarmLevel.urgent"/>';
            else if (alarmLevel == 3)
                textNode.innerHTML = '<fmt:message key="common.alarmLevel.critical"/>';
            else if (alarmLevel == 4)
                textNode.innerHTML = '<fmt:message key="common.alarmLevel.lifeSafety"/>';
            else
                textNode.innerHTML = "Unknown: "+ alarmLevel;
        }

        function setAlarmLevelImg(alarmLevel, imgNode) {
            if (alarmLevel == 0)
                updateImg(imgNode, "images/flag_green.png", "Green Flag", false, "none");
            else if (alarmLevel == 1)
                updateImg(imgNode, "images/flag_blue.png", "Blue Flag", true, "visible");
            else if (alarmLevel == 2)
                updateImg(imgNode, "images/flag_yellow.png", "Yellow Flag", true, "visible");
            else if (alarmLevel == 3)
                updateImg(imgNode, "images/flag_orange.png", "Orange Flag", true, "visible");
            else if (alarmLevel == 4)
                updateImg(imgNode, "images/flag_red.png", "Red Flag", true, "visible");
            else
                updateImg(imgNode, "(unknown)", "(unknown)", true, "visible");
        }

        window.addEventListener('beforeunload', (event) => {
            try {
                disconnect();
            } catch(error) {}
        });
    </c:if>




    </script>
  </c:if>

</head>
<body>

  <div class="scada-watch-list-xKW">

    <c:if test="${!empty sessionUser}">

      <div class="frame-1-ZaC">
        <c:if test="${sessionUser.username=='admin'}">
            <div class="frame-294-5wr">
              <img class="argos-L76" src="assets/icons/argos.png"/>

              <div class="frame-217-3nC">
                <div class="auto-group-cerz-zhS">

                  <div class="frame-2-WQt">
                    <img class="notificao-DCp" src="assets/icons/notificao.png"/>
                    <a href="events.shtm" class="informao-VAL">Informa&ccedil;&atilde;o</a>
                  </div>

                  <img title="Som" class="som-yLQ" src="assets/icons/som.png"
                      onclick="MiscDwr.toggleUserMuted(setUserMuted)"
                      onmouseover="hideLayer('localeEdit')"/>


                  <div class="idioma-VZe" onclick="showMenu('localeEdit', -40, 10);">
                    <img class="union-1H6" src="assets/icons/union-dCQ.png"/>
                    <div id="localeEdit" class="labelDiv navbar-dropdown--hidden" onmouseout="hideLayer(this)">
                      <c:forEach items="${availableLanguages}" var="lang">
                        <a class="ptr" onclick="setLocale('${lang.key}')">${lang.value}</a><br/>
                      </c:forEach>
                    </div>
                  </div>

                  <a href="help.shtm" title="Ajuda"><img class="ajuda-YH2" src="assets/icons/ajuda.png"/></a>

                  <div class="frame-1-fsS">
                    <img class="user-z92" src="assets/icons/user.png"/>
                    <div class="admin123-8FE">${sessionUser.username}</div>
                  </div>

                  <div class="frame-3-QCk">
                    <a href="logout.htm" onclick="disconnect()" class="sair-wyN">Sair
                      <img class="box-arrow-right-gRA" src="assets/icons/box-arrow-right.png"/>
                    </a>
                  </div>

                </div>
              </div>
              <img class="vector-20-nyz" src="REPLACE_IMAGE:6:368"/>
            </div>
        </c:if>

        <div class="auto-group-yb9e-YCU">
          <div class="auto-group-5vlt-Urp">
            <div class="rectangle-318-1br"></div>
            <div class="frame-294-8Ra">
              <img class="vector-263-wtp" src="REPLACE_IMAGE:6:212"/>
              <img class="graphic-view-cEG" src="assets/icons/auto-group-fxrz.png"/>
              <img class="graphic-view-cEG" src="assets/icons/graphic-view.png"/>
              <img class="flag-8TW" src="assets/icons/flag.png"/>
              <img class="relatrios-sAC" src="assets/icons/relatrios-M96.png"/>
              <img class="vector-264-1XJ" src="REPLACE_IMAGE:6:217"/>
              <img class="tratadores-de-eventos-Z32" src="assets/icons/tratadores-de-eventos.png"/>
              <img class="data-source-51N" src="assets/icons/data-source.png"/>
              <img class="eventos-agendados-DNU" src="assets/icons/eventos-agendados.png"/>
              <img class="eventos-compostos-MUg" src="assets/icons/eventos-compostos.png"/>
              <img class="points-links-h2k" src="assets/icons/points-links.png"/>
              <img class="scripting-pt4" src="assets/icons/scripting.png"/>
              <img class="vector-265-N8t" src="REPLACE_IMAGE:6:224"/>
              <img class="usurios-uPi" src="assets/icons/usurios.png"/>
              <img class="perfil-3Vv" src="assets/icons/perfil.png"/>
              <img class="hierarquia-aVr" src="assets/icons/hierarquia.png"/>
              <img class="lista-envios-ic4" src="assets/icons/lista-envios.png"/>
              <img class="published-fXJ" src="assets/icons/published.png"/>
              <img class="eventos-de-manuteno-Py6" src="assets/icons/eventos-de-manuteno.png"/>
              <img class="config-do-sistema-KLx" src="assets/icons/config-do-sistema.png"/>
              <img class="importar-exportar-SgU" src="assets/icons/importar-exportar.png"/>
              <div class="sql-mik">
                <img class="union-sfJ" src="assets/icons/union.png"/>
              </div>
              <img class="vector-266-p4k" src="REPLACE_IMAGE:6:234"/>
              <img class="star-fill-xwe" src="assets/icons/star-fill.png"/>
              <img class="favorito-urt" src="assets/icons/favorito.png"/>
            </div>
          </div>

          <!--
          <img class="vector-20-rGL" src="REPLACE_IMAGE:6:238"/>
          <div class="auto-group-5h6t-yrk">
            <div class="frame-217-KQp">
              <div class="group-218-mV6">
                <div class="frame-218-urC">
                  <div class="frame-220-eYt">
                    <p class="watch-list-An8">Watch List</p>
                    <div class="auto-group-uugg-6fn">

                      <div class="frame-3-pbn">
                        <p class="unnamed-n2p">unnamed</p>
                        <img class="chevron-down-Jmr" src="assets/icons/chevron-down.png"/>
                      </div>

                      <div class="frame-219-8Vz">
                        <img class="plus-4eY" src="assets/icons/plus.png"/>
                        <img class="edit-1Jt" src="assets/icons/edit.png"/>
                        <img class="relatrios-8uJ" src="assets/icons/relatrios.png"/>
                        <img class="file-plus-fPS" src="assets/icons/file-plus.png"/>
                      </div>
                    </div>
                  </div>
                  <div class="frame-222-Q68">
                    <p class="item-vaG">Item</p>
                    <p class="label-f24">Label</p>
                    <p class="hora-C1z">Hora</p>
                  </div>
                  <img class="vector-20-jXi" src="REPLACE_IMAGE:6:404"/>
                  <div class="frame-223-ghr">
                    <div class="auto-group-aagl-1EL">
                      <div class="checks-kBv">
                        <div class="checbox-t3E">
                        </div>
                      </div>
                      <p class="testedatasource-pressaobasf-oR6">teste_datasource-pressao_basf</p>
                    </div>
                    <p class="item-1526398478-gjn">1526398478</p>
                    <p class="item-00-00-00-brk">00:00:00</p>
                    <div class="frame-219-jCG">
                      <img class="search-fLp" src="assets/icons/search-iAg.png"/>
                      <img class="ordenar-P1v" src="assets/icons/ordenar-x4U.png"/>
                      <img class="less-Jeg" src="assets/icons/less-wBa.png"/>
                    </div>
                  </div>
                  <img class="vector-22-rRJ" src="REPLACE_IMAGE:6:414"/>
                  <div class="frame-219-btg">
                    <div class="auto-group-zavs-XnL">
                      <div class="checks-HFi">
                        <div class="checbox-d4g">
                        </div>
                      </div>
                      <p class="testedatasource-testepoint-Lzg">teste_datasource-testepoint</p>
                    </div>
                    <p class="item-1526398478-SH2">1526398478</p>
                    <p class="item-00-00-00-ZMe">00:00:00</p>
                    <div class="frame-219-Txp">
                      <img class="search-CfW" src="assets/icons/search.png"/>
                      <img class="ordenar-XBz" src="assets/icons/ordenar.png"/>
                      <img class="less-3AL" src="assets/icons/less.png"/>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        -->
        </div>
      </div>
    </c:if>

  </div>

  <!-- mainHeader -->


  <!--
    // CODIGO COMENTADO - DIEGO
  <c:if test="${!sessionUser.hideHeader}">

    <div id="mainHeader">
      <tag:logo/>

      <div id="eventsRow">
        <a href="events.shtm">
          <span id="__header__alarmLevelDiv">
            <img id="__header__alarmLevelImg" src="images/spacer.gif" alt="" border="0" title=""/>
            <span id="__header__alarmLevelText"></span>
          </span>
        </a>
      </div>

      <div>
        <c:if test="${!empty instanceDescriptionHeader}">
          <span id="instanceDescriptionHeader" align="right" valign="bottom" class="projectTitle"><a href="system_settings.shtm" style="text-decoration: none;color:grey">${instanceDescriptionHeader}</a></span>
        </c:if>
      </div>
    </div>


    <c:if test="${!simple}">
      <div class="navHeader" id="subHeader">
        <div>
          <nav class="flex-default">
            <c:if test="${isLoggedToScadaUser}">
              <div class="spacer">
                  <c:choose>
                      <c:when test="${sessionUser.hideMenu}">
                          <c:if test="${!empty sessionUser.homeUrl}">
                              <c:set var="homeUrl" value="${fn:split(sessionUser.homeUrl, '?')}" />
                              <c:if test="${homeUrl[0] == 'app.shtm'}">
                                  <tag:menuItem href="app.shtm#/watch-list" png="desktop" key="header.newui"/>
                                  <img src="./images/menu_separator.png" class="separator"/>
                              </c:if>
                              <c:if test="${homeUrl[0] == 'watch_list.shtm'}">
                                  <tag:menuItem href="watch_list.shtm" png="eye" key="header.watchlist"/>
                              </c:if>
                              <c:if test="${homeUrl[0] == 'views.shtm'}">
                                <tag:menuItem href="views.shtm" png="icon_view" key="header.views"/>
                              </c:if>
                              <c:if test="${homeUrl[0] == 'events.shtm'}">
                                <tag:menuItem href="events.shtm" png="flag_white" key="header.alarms"/>
                              </c:if>
                              <c:if test="${homeUrl[0] == 'reports.shtm'}">
                                <tag:menuItem href="reports.shtm" png="report" key="header.reports"/>
                              </c:if>
                          </c:if>
                      </c:when>

                  <c:otherwise>
                      <tag:menuItem href="app.shtm#/watch-list" png="desktop" key="header.newui"/>
                      <img src="./images/menu_separator.png" class="separator"/>
                      <tag:menuItem href="watch_list.shtm" png="eye" key="header.watchlist"/>
                      <tag:menuItem href="views.shtm" png="icon_view" key="header.views"/>
                      <tag:menuItem href="events.shtm" png="flag_white" key="header.alarms"/>
                      <tag:menuItem href="reports.shtm" png="report" key="header.reports"/>
                  </c:otherwise>
                </c:choose>
              </div>


              <c:if test="${sessionUser.admin}">
                <div class="spacer">
                  <img src="./images/menu_separator.png" class="separator"/>
                  <tag:menuItem href="event_handlers.shtm" png="cog" key="header.eventHandlers"/>
                  <tag:menuItem href="data_sources.shtm" png="icon_ds" key="header.dataSources"/>
                  <tag:menuItem href="scheduled_events.shtm" png="clock" key="header.scheduledEvents"/>
                  <tag:menuItem href="compound_events.shtm" png="multi_bell" key="header.compoundEvents"/>
                  <tag:menuItem href="point_links.shtm" png="link" key="header.pointLinks"/>
                  <tag:menuItem href="scripting.shtm" png="script_gear" key="header.scripts"/>
                </div>
              </c:if>

              <div class="spacer">
                <img src="./images/menu_separator.png" class="separator"/>
                <tag:menuItem href="users.shtm" png="user" key="header.users"/>
              </div>

              <c:if test="${sessionUser.admin}">
                <div class="spacer">
                  <tag:menuItem href="usersProfiles.shtm" png="user_ds" key="header.usersProfiles"/>
                  <tag:menuItem href="pointHierarchySLTS" png="folder_brick" key="header.pointHierarchy"/>
                  <tag:menuItem href="mailing_lists.shtm" png="book" key="header.mailingLists"/>
                  <tag:menuItem href="publishers.shtm" png="transmit" key="header.publishers"/>
                  <tag:menuItem href="maintenance_events.shtm" png="hammer" key="header.maintenanceEvents"/>
                  <tag:menuItem href="system_settings.shtm" png="application_form" key="header.systemSettings"/>
                  <tag:menuItem href="emport.shtm" png="script_code" key="header.emport"/>
                  <tag:menuItem href="sql.shtm" png="script" key="header.sql"/>
                </div>
              </c:if>

              <div class="spacer">
                <img src="./images/menu_separator.png" class="separator"/>
                <span onclick="disconnect()">
                <tag:menuItem href="logout.htm" png="control_stop_blue" key="header.logout"/>
                </span>
                <tag:menuItem href="help.shtm" png="help" key="header.help"/>
              </div>

            </c:if>

            <c:if test="${isRolePublic}">
              <div class="spacer">
                <img src="./images/menu_separator.png" class="separator"/>
                <span onclick="disconnect()">
                <tag:menuItem href="logout.htm" png="control_stop_blue" key="header.logout"/>
                </span>
                <tag:menuItem href="help.shtm" png="help" key="header.help"/>
              </div>
            </c:if>

            <c:if test="${empty sessionUser}">
                <tag:menuItem href="login.htm" png="control_play_blue" key="header.login"/>
            </c:if>
            <div id="headerMenuDescription" class="labelDiv" style="position:absolute;display:none;"></div>
          </nav>
        </div>

        <div class="flex-default">
          <div id="navbarUserInfo">
            <c:if test="${isLoggedToScadaUser}">
              <span class="copyTitle"><fmt:message key="header.user"/>:</span>
              <c:choose>
                  <c:when test="${!empty sessionUser.firstName}">
                    <span class="userName"><c:out value="${sessionUser.firstName} ${sessionUser.lastName}"/></span>
                  </c:when>
                  <c:otherwise>
                    <span class="userName"><c:out value="${sessionUser.username}"/></span>
                  </c:otherwise>
              </c:choose>
            </c:if>
          </div>


          <div id="navbarUserProperties" class="flex-default spacer">
            <c:if test="${isLoggedToScadaUser}">
              <c:if test="${!sessionUser.hideMenu}">
                  <tag:img id="userMutedImg" onclick="MiscDwr.toggleUserMuted(setUserMuted)" onmouseover="hideLayer('localeEdit')"/>
                  <tag:img png="house" title="header.goHomeUrl" onclick="goHomeUrl()" onmouseover="hideLayer('localeEdit')"/>
                  <tag:img png="house_link" title="header.setHomeUrl" onclick="setHomeUrl()" onmouseover="hideLayer('localeEdit')"/>
              </c:if>
            </c:if>

            <div class="ptr" onmouseover="showMenu('localeEdit', -40, 10);">
              <tag:img png="world" title="header.changeLanguage"/>
              <div id="localeEdit" class="labelDiv navbar-dropdown--hidden" onmouseout="hideLayer(this)">
                <c:forEach items="${availableLanguages}" var="lang">
                  <a class="ptr" onclick="setLocale('${lang.key}')">${lang.value}</a><br/>
                </c:forEach>
              </div>
            </div>

          </div>
        </div>
      </div>
    </c:if>
  </c:if>

  -->











  <div id="sltsContent" class="content">
    <jsp:doBody/>
  </div>
  <div id="sltsFooter" class="footer">
      <span>&copy;2012-${toYear} Scada-LTS <fmt:message key="footer.rightsReserved"/><span>
  </div>

  <c:if test="${!!sessionUser.hideHeader}">
      <div class="notification-alert--reset">
          <span class="clickable" onclick="resetHideView()">Exit from embedded view</span>
      </div>

      <script type="text/javascript">
      function resetHideView() {
          let loc = window.location.href.split('/');
          window.location = loc[0] + "//" + loc[2] + "/" + loc[3] + "/watch_list.shtm";
      }
      </script>
  </c:if>

  <c:if test="${!empty onload}">
    <script type="text/javascript">dojo.addOnLoad(${onload});</script>
  </c:if>














  <script>
    hideLayer('localeEdit')
  </script>
</body>
</html>
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
  <title><c:choose>
    <c:when test="${!empty instanceDescriptionHeader}">${instanceDescriptionHeader}</c:when>
    <c:otherwise><fmt:message key="header.title"/></c:otherwise>
  </c:choose></title>

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
            textNode = document.getElementB-yId(textNode);
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
        // Função para definir a imagem do nível de alarme com base no nível de alarme fornecido.
        // Dependendo do valor de 'alarmLevel', a função atualiza o ícone 'iconNode' com diferentes classes, descrições e visibilidades.
        // alarmLevel: Nível do alarme (0 a 4, onde 0 é o mais baixo e 4 é o mais alto).
        // iconNode: O nó do ícone que será atualizado. 
         function setAlarmLevelImg(alarmLevel, iconNode) {
            if (alarmLevel == 0)
                updateIcon(iconNode, "bi bi-flag-fill text-success", "Green Flag", false, "none");
            else if (alarmLevel == 1)
                updateIcon(iconNode, "bi bi-flag-fill text-primary", "Blue Flag", true, "visible");
            else if (alarmLevel == 2)
                updateIcon(iconNode, "bi bi-flag-fill text-warning", "Yellow Flag", true, "visible");
            else if (alarmLevel == 3)
                updateIcon(iconNode, "bi bi-flag-fill text-orange", "Orange Flag", true, "visible"); // text-orange is not a default Bootstrap class, you might need to define it
            else if (alarmLevel == 4)
                updateIcon(iconNode, "bi bi-flag-fill text-danger", "Red Flag", true, "visible");
            else
                updateIcon(iconNode, "bi bi-question-circle-fill", "(unknown)", true, "visible");
        }
        
        function updateIcon(imgNode, className, text, visible, styleType) {
            if (visible) {
                if (imgNode != null) {
                    imgNode = getNodeIfString(imgNode);
                    show(imgNode, styleType);
                    if (className)
                        imgNode.className = className;
                    if (text) {
                        imgNode.title = text;
                        imgNode.alt = text;
                    }
                }
            }
            else
                hide(imgNode);
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

<!-- mainHeader -->
<c:if test="${!sessionUser.hideHeader}">
	<div id="mainHeader" style="height: 75px; display: flex; justify-content: space-between; align-items: center;">
		<tag:logo/>
        <div class="btn-group">
            <button class="avatar text-bg-primary dropdown" type="button" data-bs-toggle="dropdown" data-bs-auto-close="false" aria-expanded="false">
                <div>
                    <c:if test="${isLoggedToScadaUser}">
                        <c:choose>
                            <c:when test="${!empty sessionUser.firstName}">
                                <span class="userName"><c:out value="${fn:substring(sessionUser.firstName, 0, 1)}"/></span>
                            </c:when>
                            <c:otherwise>
                                <span class="userName"><c:out value="${fn:substring(sessionUser.username, 0, 1)}"/></span>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                </div>
            </button>
                <ul class="dropdown-menu">
                    <li>
                        <a class="dropdown-item">
                            <div class="copyTitle"><fmt:message key="header.user"/></div>
                            <div class="text-secondary"><c:out value="${sessionUser.firstName} ${sessionUser.lastName}"/></div>
                        </a>
                    </li>
                    <li><hr class="dropdown-divider"></li>
                    <li class="dropdown-submenu dropstart">
                        <a class="dropdown-item dropdown-toggle" href="#">
                            <i class="bi bi-translate me-2"></i><fmt:message key='header.changeLanguage'/>
                        </a>
                        <ul class="dropdown-menu dropdown-submenu">
                            <li><a class="dropdown-item" href="#">Menu item</a></li>
                            <li><a class="dropdown-item" href="#">Menu item</a></li>
                            <li><a class="dropdown-item" href="#">Menu item</a></li>
                        </ul>
                    </li>
                    <li><a class="dropdown-item" href="system_settings.shtm">
                        <i class="bi bi-sliders me-2">
                        </i><fmt:message key='header.systemSettings'/></a>
                    </li>
                    <li><a class="dropdown-item" href="help.shtm">
                        <i class="bi bi-question-circle me-2"></i>
                        <fmt:message key='header.help'/></a>
                    </li>
                    <li><a class="dropdown-item" href="logout.htm" onclick="disconnect()">
                        <i class="bi bi-door-open me-2"></i>
                        <fmt:message key='header.logout'/></a>
                    </li>
                </ul>
        </div>
	</div>    

	<!-- subheader -->
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
                                    <div class="horizontal-menu">
                                            <a href="watch_list.shtm" class="nav-link" title="<fmt:message key='header.watchlist'/>">
                                                <i class="bi bi-layout-text-window-reverse"></i>
                                            </a>
                                            <a href="views.shtm" class="nav-link" title="<fmt:message key='header.views'/>">
                                                <i class="bi bi-diagram-3"></i>
                                            </a>
                                            <a href="events.shtm" class="nav-link" title="<fmt:message key='header.alarms'/>">
                                                <i class="bi bi-flag"></i>
                                            </a>
                                            <a href="reports.shtm" class="nav-link" title="<fmt:message key='header.reports'/>">
                                                <i class="bi bi-clipboard2-pulse"></i>
                                            </a>
                                    </div>
								</c:otherwise>
							</c:choose>
						</div>

						<c:if test="${sessionUser.admin}">
              <div class="horizontal-menu">
                      <a href="event_handlers.shtm" class="nav-link" title="<fmt:message key='header.eventHandlers'/>">
                          <i class="bi bi-gear"></i>
                      </a>
                      <a href="data_sources.shtm"" class="nav-link" title="<fmt:message key='header.dataSources'/>">
                          <i class="bi bi-database-add"></i>
                      </a>
                      <a href="scheduled_events.shtm" class="nav-link" title="<fmt:message key='header.scheduledEvents'/>">
                          <i class="bi bi-calendar-check"></i>
                      </a>
                      <a href="compound_events.shtm" class="nav-link" title="<fmt:message key='header.compoundEvents'/>">
                          <i class="bi bi-calendar-week"></i>
                      </a>
                      <a href="point_links.shtm" class="nav-link" title="<fmt:message key='header.pointLinks'/>">
                          <i class="bi bi-arrow-left-right"></i>
                      </a>
                      <a href="scripting.shtm" class="nav-link" title="<fmt:message key='header.scripts'/>">
                          <i class="bi bi-journal-code"></i>
                      </a>
              </div>
						</c:if>
              <div class="horizontal-menu">
                      <a href="users.shtm" class="nav-link" title="<fmt:message key='header.users'/>">
                          <i class="bi bi-people"></i>
                      </a>
						  </div>

						<c:if test="${sessionUser.admin}">
                            <div class="horizontal-menu">
                                <a href="usersProfiles.shtm" class="nav-link" title="<fmt:message key='header.usersProfiles'/>">
                                    <i class="bi bi-person-vcard"></i>
                                </a>
                                <a href="pointHierarchySLTS"" class="nav-link" title="<fmt:message key='header.pointHierarchy'/>">
                                    <i class="bi bi-menu-app"></i>
                                </a>
                                <a href="mailing_lists.shtm" class="nav-link" title="<fmt:message key='header.mailingLists'/>">
                                    <i class="bi bi-journal-arrow-up"></i>
                                </a>
                                <a href="publishers.shtm" class="nav-link" title="<fmt:message key='header.publishers'/>">
                                    <i class="bi bi-broadcast-pin"></i>
                                </a>
                                <a href="maintenance_events.shtm" class="nav-link" title="<fmt:message key='header.maintenanceEvents'/>">
                                    <i class="bi bi-wrench-adjustable-circle"></i>
                                </a>
                                <a href="system_settings.shtm" class="nav-link" title="<fmt:message key='header.systemSettings'/>">
                                    <i class="bi bi-sliders"></i>
                                </a>
                                <a href="emport.shtm" class="nav-link" title="<fmt:message key='header.emport'/>">
                                    <i class="bi bi-floppy"></i>
                                </a>
                                <a href="sql.shtm" class="nav-link" title="<fmt:message key='header.sql'/>">
                                    <i class="bi bi-filetype-sql"></i>
                                </a>
                            </div>
						</c:if>

						<div class="spacer">
                            <div class="horizontal-menu">
                                <span onclick="disconnect()">
                                    <a href="logout.htm" class="nav-link" title="<fmt:message key='header.logout'/>">
                                        <i class="bi bi-door-open"></i>
                                    </a>
                                </span>
                                    <a href="help.shtm" class="nav-link" title="<fmt:message key='header.help'/>">
                                        <i class="bi bi-question-circle"></i>
                                    </a>
                            </div>
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
                        <div class="horizontal-menu">
                            <a href="#" id="userMutedImg" class="nav-link" onclick="MiscDwr.toggleUserMuted(setUserMuted)" onmouseover="hideLayer('localeEdit')" title="<fmt:message key='header.userMuted'/>">
                            </a>
                            <a href="#" class="nav-link" onclick="goHomeUrl()" onmouseover="hideLayer('localeEdit')" title="<fmt:message key='header.goHomeUrl'/>">
                                <i class="bi bi-house"></i>
                            </a>
                            <a href="#" class="nav-link" onclick="setHomeUrl()" onmouseover="hideLayer('localeEdit')" title="<fmt:message key='header.setHomeUrl'/>">
                                <i class="bi bi-house-door"></i>
                            </a>
                        </div>
					</c:if>
                        <div class="ptr" onmouseover="showMenu('localeEdit', -100, 5);">
                                <a href="#" class="nav-link" title="<fmt:message key='header.changeLanguage'/>">
                                    <i class="bi bi-translate"></i>
                                </a>
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
<div class="container-fluid">
    <div id="sltsContent" class="content">
    <jsp:doBody/>
    </div>
</div>
<div id="sltsFooter" class="footer sticky-footer text-center m-3">
    <span>
        &copy;2012-${toYear} Argos SCADA
        <fmt:message key="footer.rightsReserved"/>
    </span>
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

</body>
</html>

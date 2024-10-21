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
<%@ include file="/WEB-INF/jsp/include/tech.jsp" %>
<%@page import="com.serotonin.mango.Common"%>

<tag:page dwr="UsersDwr" onload="init">
  <script type="text/javascript">
    var userId = ${sessionUser.id};
    var editingUserId;
    var dataSources;
    var adminUser;
    
    function init() {
      UsersDwr.getInitData(function(data) {
            if (data.admin) {
              show("usersProfilesListTable");
                adminUser = true;
                
                show("userList");
                show("usernameRow");
                show("administrationRow");
                show("disabledRow");
                show("hideMenuRow");
                show("homeUrlRow");
                show("deleteImg");
                show("sendTestEmailImg");
                
                var i, j;
                for (i=0; i<data.users.length; i++) {
                    appendUser(data.users[i].id);
                    updateUser({user: data.users[i]});
                }

                var usersProfileHtml = "", userProfileId, userProfileName;
                usersProfileHtml += "<option value=" + <c:out value="<%= Common.NEW_ID %>"/> + ">"+ "<fmt:message key="userProfiles.none"/>" + "</option>";
                
                for (k=0; k<data.usersProfiles.length; k++) {
                  userProfileId = data.usersProfiles[k].id;
                  userProfileName = data.usersProfiles[k].name;
                  usersProfileHtml += "<option value=" + userProfileId + ">"+ userProfileName + "</option>";
                }
                $("usersProfilesList").innerHTML = usersProfileHtml;
                
                var dshtml = "", id, dp;
                dataSources = data.dataSources;
                for (i=0; i<dataSources.length; i++) {
                    id = "ds"+ dataSources[i].id;
                    dshtml += '<input  class="form-check-input custom-checkbox" type="checkbox" id="'+ id +'" onclick="dataSourceChange(this)">';
                    dshtml += '<label class="text-center w-50 fs-6" for="'+ id +'"> '+ dataSources[i].name +'</label><br/>';
                    dshtml += '<div style="margin-left:25px;" id="dsps'+ dataSources[i].id +'">';
                    if (dataSources[i].points.length > 0) {
                        dshtml +=   '<table cellspacing="0" cellpadding="1" class="table table-light table-hover">';
                        for (j=0; j<dataSources[i].points.length; j++) {
                            dp = dataSources[i].points[j];
                            dshtml += '<tr>';
                            dshtml +=   '<td class="col-sm-3 col-form-label custom-padding-l  my-2">'+ dp.name +'</td>';
                            dshtml +=   '<td>';
                            dshtml +=     '<input  class="form-check-input my-2 align-middle" type="radio" name="dp'+ dp.id +'" id="dp'+ dp.id +'/0" value="0">';
                            dshtml +=             '<label class="mx-3" for="dp'+ dp.id +'/0"><fmt:message key="common.access.none"/></label> ';
                            dshtml +=     '<input  class="form-check-input my-2 align-middle" type="radio" name="dp'+ dp.id +'" id="dp'+ dp.id +'/1" value="1">';
                            dshtml +=             '<label class="mx-3" for="dp'+ dp.id +'/1"><fmt:message key="common.access.read"/></label> ';
                            if (dp.settable) {
                                dshtml +=     '<input  class="form-check-input my-2 align-middle" type="radio" name="dp'+ dp.id +'" id="dp'+ dp.id +'/2" value="2">';
                                dshtml +=             '<label class="mx-3" for="dp'+ dp.id +'/2"><fmt:message key="common.access.set"/></label>';
                            }
                            dshtml +=   '</td>';
                            dshtml += '</tr>';
                        }
                        dshtml +=   '</table>';
                    }
                    dshtml += '</div>';
                }
                $("dataSourceList").innerHTML = dshtml;
            }
            else {
              
                // Not an admin user.
                adminUser = false;
                editingUserId = data.user.id;
                showUserCB(data);
                hide("usersProfilesListTable");
            }
        });
    }
    
    function showUser(userId, hideMsg) {
      if (userId == -1)
        hide($('deleteImg'));
      else
        show($('deleteImg'));
      if (hideMsg)
            setUserMessage();
            
        if (editingUserId)
            stopImageFader($("u"+ editingUserId +"Img"));
        editingUserId = userId;
        UsersDwr.getUser(userId, showUserCB);
        startImageFader($("u"+ editingUserId +"Img"));
    }
    
    function showUserCB(response) {
        var user = response.data ? response.data.user : response.user;
        var forceFullScreenMode = response.data ? response.data.forceFullScreenMode : response.forceFullScreenMode;
        var forceHideShortcutDisableFulLScreen = response.data ? response.data.forceHideShortcutDisableFulLScreen : response.forceHideShortcutDisableFulLScreen;
        show($("userDetails"));
        if(forceFullScreenMode) {
            document.getElementById("enableFullScreen").disabled = true;
            document.getElementById("enableFullScreen").title = '<fmt:message key="user.view.forceAdminTitle"/>';
        } else {
            document.getElementById("enableFullScreen").disabled = false;
            document.getElementById("enableFullScreen").title = '<fmt:message key="user.view.enableFullScreen"/>';
        }
        if(forceHideShortcutDisableFulLScreen) {
            document.getElementById("hideShortcutDisableFullScreen").disabled = true;
            document.getElementById("hideShortcutDisableFullScreen").title = '<fmt:message key="user.view.forceAdminTitle"/>';
        } else {
            document.getElementById("hideShortcutDisableFullScreen").disabled = false;
            document.getElementById("hideShortcutDisableFullScreen").title = '<fmt:message key="user.view.hideShortcutDisableFullScreen"/>';
        }
        $set("username", user.username);
        $set("firstName", user.firstName);
        $set("lastName", user.lastName);
        $set("password", user.password);
        $set("email", user.email);
        $set("phone", user.phone);
        $set("administrator", user.admin);
        $set("disabled", user.disabled);
        $set("receiveAlarmEmails", user.receiveAlarmEmails);
        $set("receiveOwnAuditEvents", user.receiveOwnAuditEvents);
        $set("hideMenu", user.hideMenu);
        $set("homeUrl", user.homeUrl);
        $set("theme", user.theme);
        $set("hideShortcutDisableFullScreen", user.hideShortcutDisableFullScreen);
        $set("enableFullScreen", user.enableFullScreen);


        if(user.id != <c:out value="<%= Common.NEW_ID %>"/>) {
          $set("usersProfilesList", user.userProfile);
        	 //console.log("User profile: " + user.userProfile);
        }
        
        if (adminUser) {
            // Turn off all data sources and set all data points to 'none'.
            var i, j, dscb, dp;
            for (i=0; i<dataSources.length; i++) {
                dscb = $("ds"+ dataSources[i].id);
                dscb.checked = false;
                dataSourceChange(dscb);
                for (j=0; j<dataSources[i].points.length; j++)
                    $set("dp"+ dataSources[i].points[j].id, "0");
            }
            
            // Turn on the data sources to which the user has permission.
            for (i=0; i<user.dataSourcePermissions.length; i++) {
                dscb = $("ds"+ user.dataSourcePermissions[i]);
                dscb.checked = true;
                dataSourceChange(dscb);
            }
            
            // Update the data point permissions.
            for (i=0; i<user.dataPointPermissions.length; i++)
                $set("dp"+ user.dataPointPermissions[i].dataPointId, user.dataPointPermissions[i].permission);
            stopImageFader($("u"+ user.id +"Img"));
        }

        //setUserMessage();
        updateUserImg();
    }

    function setDataSourcesNone() {
        var i;
        for (i=0; i<dataSources.length; i++) {
            dscb = $("ds"+ dataSources[i].id);
            dscb.checked = false;
            dataSourceChange(dscb);
            for (j=0; j<dataSources[i].points.length; j++)
                $set("dp"+ dataSources[i].points[j].id, "0");
        }
    }

    function hideDataSources() {
      hide("dataSources");
    }

    function showDataSources() {
      show("dataSources");
    }
    
    function checkProfile(){
      var profile = document.getElementById("usersProfilesList");
      if(profile.options[profile.selectedIndex].value > 0){
        hideDataSources();
        }else{
    		//setDataSourcesNone();
        showDataSources();
        }
    }
    
    function saveUser() {
		startImageFader($("saveImg"));
    
		setUserMessage();
        if (adminUser) {
          startImageFader($("u"+ editingUserId +"Img"));
           // Create the list of allowed data sources and data point permissions.
            var i, j;
            var dsPermis = new Array();
            var dpPermis = new Array();
            var dpval;
            
            // If a profile is select, reset other permissions on DSs.
            if($get("usersProfileList") == <c:out value="<%= Common.NEW_ID %>"/>)
            {
              setDataSourcesNone();
            }

            if($get("usersProfileList") != <c:out value="<%= Common.NEW_ID %>"/>) {
                for (i=0; i<dataSources.length; i++) {
                    if ($("ds"+ dataSources[i].id).checked)
                        dsPermis[dsPermis.length] = dataSources[i].id;
                    else {
                        for (j=0; j<dataSources[i].points.length; j++) {
                            dpval = $get("dp"+ dataSources[i].points[j].id);
                            if (dpval == "1" || dpval == "2")
                                dpPermis[dpPermis.length] = {dataPointId: dataSources[i].points[j].id, permission: dpval};
                        }
                    }
                }
            }
            
            UsersDwr.saveUserAdmin(editingUserId, $get("username"), $get("firstName"), $get("lastName"), $get("password"), $get("email"), $get("phone"),
                    $get("administrator"), $get("disabled"), $get("receiveAlarmEmails"), $get("receiveOwnAuditEvents"),
                    dsPermis, dpPermis, $get("usersProfilesList"), $get("hideMenu"), $get("theme"), parseHomeUrl($get("homeUrl")),
                    $get("enableFullScreen"), $get("hideShortcutDisableFullScreen"), saveUserCB);
        }
        else
            UsersDwr.saveUser(editingUserId, $get("firstName"), $get("lastName"), $get("password"), $get("email"), $get("phone"),
                    $get("receiveAlarmEmails"), $get("receiveOwnAuditEvents"), $get("usersProfilesList"),
                    $get("theme"), $get("enableFullScreen"), $get("hideShortcutDisableFullScreen"), saveUserCB);
    }
    
    function saveUserCB(response) {
        stopImageFader($("saveImg"));
        if (response.hasMessages)
            showDwrMessages(response.messages, "genericMessages");
        else if (!adminUser)
            setUserMessage("<fmt:message key="users.dataSaved"/>");
        else {
            if (editingUserId == <c:out value="<%= Common.NEW_ID %>"/>) {
                stopImageFader($("u"+ editingUserId +"Img"));
                editingUserId = response.data.userId;
                appendUser(editingUserId);
                startImageFader($("u"+ editingUserId +"Img"));
                setUserMessage("<fmt:message key="users.added"/>");
                UsersDwr.getUser(editingUserId, updateUser);
                showUser(editingUserId, false);
            }
            else {
              setUserMessage("<fmt:message key="users.saved"/>");
              UsersDwr.getUser(editingUserId, updateUser);
              showUser(editingUserId, false);
                }
            
        }
    }
    
    function sendTestEmail() {
        UsersDwr.sendTestEmail($get("email"), $get("username"), function(result) {
            stopImageFader($("sendTestEmailImg"));
            if (result.exception)
                setUserMessage(result.exception);
            else
                setUserMessage(result.message);
        });
        startImageFader($("sendTestEmailImg"));
    }
    
    function setUserMessage(message) {
        if (message){
            $set("userMessage", message);
        //console.log("show message - " + message);
        }
        else {
            $set("userMessage");
            //console.log("hide messages");
            hideContextualMessages("userDetails");
            hideGenericMessages("genericMessages");
        }
    }
    
    function appendUser(userId) {
        createFromTemplate("u_TEMPLATE_", userId, "usersTable");
    }
    
    function updateUser(response) {
        var user = response.data ? response.data.user : response.user;
        $("u"+ user.id +"Username").innerHTML = user.username;
        setUserImg(user.admin, user.disabled, $("u"+ user.id +"Img"));
    }
    
    function updateUserImg() {
        var admin = $get("administrator");
        if (adminUser) {
            if (admin) {
              $("usersProfilesList").disabled = true;
                    $("hideMenu").disabled = true;
            }
            else {
              $("usersProfilesList").disabled = false;
                    $("hideMenu").disabled = false;
            }
            checkProfile();
        }
        setUserImg(admin, $get("disabled"), $("userImg"));
    }
    
    function dataSourceChange(dscb) {
        display("dsps"+ dscb.id.substring(2), !dscb.checked);
    }
    
    function deleteUser() {
        if (confirm("<sst:i18n key="users.deleteConfirm" escapeDQuotes="true"/>")) {
          var userId = editingUserId;
            startImageFader("deleteImg");
            UsersDwr.deleteUser(userId, function(response) {
                stopImageFader("deleteImg");
                
                if (response.hasMessages)
                setUserMessage(response.messages[0].genericMessage);
                else {
                    stopImageFader("u"+ userId +"Img");
                    $("usersTable").removeChild($("u"+ userId));
                    hide("userDetails");
                    editingUserId = null;
                }
            });
        }
    }

    function parseHomeUrl(homeUrl) {
      while(homeUrl.charAt(0) === '/') {
        homeUrl = homeUrl.substring(1);
      }
      return homeUrl.endsWith('/') ? homeUrl.slice(0, -1) : homeUrl;
    }
  </script>
  
  <table class="subPageHeader container">
    <tr>
      <td valign="top" id="userList" style="display:none;">
        <div class="left-menu">
        <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
          <span class="smallTitle"><fmt:message key="users.title"/></span>
          <tag:help id="userAdministration"/>
        </div>
        <div>
          <i class="bi bi-person-plus-fill text-blue-add align-middle ms-3 fs-5" onclick="showUser(${applicationScope['constants.Common.NEW_ID']}, false)"title="<fmt:message key='users.add'/>" id="u${applicationScope['constants.Common.NEW_ID']}Img"></i>
                <%-- <span style="font-size: 16px;">
                  <sst:i18n key='users.add' escapeDQuotes='true'/>
                </span> --%>
        </div>
        </div>
        <div class="top-row-d-flex justify-content-between container py-2 box mb-3">
          <table id="usersTable">
            <tbody id="u_TEMPLATE_" onclick="showUser(getMangoId(this), true)" class="ptr" style="display:none;"><tr>
              <td>
                <i class="bi bi-person-circle align-middle ms-3 fs-5" id="u_TEMPLATE_Img" title="<fmt:message key='users.user'/>"></i>
              </td>
              <td class="text-uppercase fs-7" id="u_TEMPLATE_Username"></td>
            </tr></tbody>
          </table>
        </div>
        </div>
      </td>
      
      <td valign="top" style="display:none;" id="userDetails">
        <div class="right-box">
            <div class="d-flex justify-content-between container py-2 box mb-3">
              <div>
                <span class="smallTitle"><i id="userImg" class="bi bi-person-circle me-2 fs-5" title="<fmt:message key='users.user'/>"></i>
                <fmt:message key="users.details"/></span>
              </div>
              <div class="d-flex justify-content-between align-items-center">
                <i id="saveImg" class="bi bi-floppy2-fill text-blue-add  me-2 fs-5" onclick="saveUser();" title="<fmt:message key='common.save'/>"></i>
                  <span style="font-size: 16px;">
                  <sst:i18n key='common.save' escapeDQuotes='true'/>
                  </span>
                <i id="deleteImg" class="bi bi-trash  text-danger ms-2 me-2 fs-5" onclick="deleteUser();" title="<fmt:message key='common.delete'/>" style="display:none;">
                  <span style="font-size: 16px; color: var(--slts-color-primary-text);">
                  <sst:i18n key='common.delete' escapeDQuotes='true'/>
                  </span></i>
                <i id="sendTestEmailImg" class="bi bi-envelope ms-2 me-2 fs-5" onclick="sendTestEmail();" title="<fmt:message key='common.sendTestEmail'/>" style="display:none;">
                  <span style="font-size: 16px;">
                  <sst:i18n key='common.sendTestEmail' escapeDQuotes='true'/>
                  </span></i>
              </div>
            </div>
          
          <div class="m-4">
          <table><tbody id="genericMessages"></tbody></table>
          
          <table class="w-100">
            <tr>
              <td colspan="2" id="userMessage" class="formError"></td>
            </tr>
            <tr id="usernameRow" style="display:none;">
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.username"/></td>
              <td class="formField col-sm-5"><input class="form-control form-control-sm my-2" id="username" type="text"/></td>
            </tr>
            <tr id="firstNameRow">
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.firstName"/></td>
              <td class="formField"><input class="form-control form-control-sm my-2" id="firstName" type="text"/></td>
            </tr>
            <tr id="lastNameRow">
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.lastName"/></td>
              <td class="formField"><input class="form-control form-control-sm my-2" id="lastName" type="text"/></td>
            </tr>
            <tr>
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.newPassword"/></td>
              <td class="formField"><input class="form-control form-control-sm my-2" id="password" type="text"/></td>
            </tr>
            <tr>
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.email"/></td>
              <td class="formField"><input class="form-control form-control-sm my-2" id="email" type="text" class="formLong"/></td>
            </tr>
            <tr>
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.phone"/></td>
              <td class="formField"><input class="form-control form-control-sm my-2" id="phone" type="text"/></td>
            </tr>
            <tr id="administrationRow" style="display:none;">
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="common.administrator"/></td>
              <td class="formField"><input  class="form-check-input custom-checkbox my-2" id="administrator" type="checkbox" onclick="updateUserImg();"/></td>
            </tr>
            <tr id="disabledRow" style="display:none;">
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="common.disabled"/></td>
              <td class="formField"><input  class="form-check-input custom-checkbox my-2" id="disabled" type="checkbox" onclick="updateUserImg();"/></td>
            </tr>
            <tr>
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.receiveAlarmEmails"/></td>
              <td class="formField"><select class="form-select form-select-sm my-2" id="receiveAlarmEmails"><tag:alarmLevelOptions/></select></td>
            </tr>
            <tr>
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.receiveOwnAuditEvents"/></td>
              <td class="formField"><input  class="form-check-input custom-checkbox my-2" id="receiveOwnAuditEvents" type="checkbox"/></td>
            </tr>
            <tr id="hideMenuRow" style="display:none;">
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.hideMenu"/></td>
              <td class="formField"><input  class="form-check-input custom-checkbox my-2" id="hideMenu" type="checkbox"/></td>
            </tr>
            <tr id="homeUrlRow" style="display:none;">
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.homeUrl"/></td>
              <td class="formField"><input class="form-control form-control-sm my-2" id="homeUrl" type="text"/></td>
            </tr>
            <tr>
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.theme"/></td>
              <td class="formField"><select class="form-select form-select-sm my-2" id="theme"><tag:ScadaThemeOptions/></select></td>
            </tr>
            <tbody id="usersProfilesListTable" style="display:none;">
            <tr>
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="userProfiles.selectName"/></td>
              <td class="formField"><select class="form-select form-select-sm my-2" id="usersProfilesList" onchange="checkProfile()">
              </select></td>
            </tr>
            </tbody>
            <tr>
            <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="user.view.enableFullScreen"/></td>
            <td class="formField"><input  class="form-check-input custom-checkbox my-2" type="checkbox" id="enableFullScreen" /></td>
            </tr>
            <tr>
            <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="user.view.hideShortcutDisableFullScreen"/></td>
            <td class="formField"><input  class="form-check-input custom-checkbox my-2" type="checkbox" id="hideShortcutDisableFullScreen" /></td>
            </tr>
            </div>
            
            <tbody id="dataSources" style="display:none;">
              <tr><td class="m-4" colspan="2"><hr class="border border-secondary w-100 my-4"/></td></tr>
              <tr class="text-center w-5 fs-6" id="dataSources">
                <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="users.dataSources"/></td>
                <td class="formField" id="dataSourceList"></td>
              </tr>
            </tbody>
          </table>
          </div>
        </div>
      </td>
    </tr>
  </table>
</tag:page>
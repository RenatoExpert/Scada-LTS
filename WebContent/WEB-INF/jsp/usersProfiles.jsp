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

<tag:page dwr="UsersProfilesDwr" onload="init">
  <script type="text/javascript">
    var userId = ${sessionUser.id};
    var editingUserProfileId;
    var dataSources;
    var watchlists;
    var views;
    var adminUser;
    var keyTranslations;
    
    function init() {
        UsersProfilesDwr.getInitData(function(data) {
            adminUser = true;
            
            show("userProfileList");
            show("userProfileNameRow");
            show("dataSources");
            show("watchlists");
            show("views");
            
            var i, j;
            for (i=0; i<data.profiles.length; i++) {
            appendUserProfile(data.profiles[i].id);
            updateUserProfile(data.profiles[i]);
            }
            
            var dshtml = "", id, dp;
            dataSources = data.dataSources;
            if (dataSources != null){
            for (i=0; i<dataSources.length; i++) {
                  id = "ds"+ dataSources[i].id;
                  dshtml += '<input  class="form-check-input custom-checkbox my-2 mx-5" type="checkbox" id="'+ id +'" onclick="dataSourceChange(this)">';
                  dshtml += '<label class="text-center w-50 fs-6" for="'+ id +'"> '+ dataSources[i].name +'</label><br/>';
                  dshtml += '<div style="margin-left:25px;" id="dsps'+ dataSources[i].id +'">';
                  if (dataSources[i].points.length > 0) {
                      dshtml +=   '<table cellspacing="0" cellpadding="1" class="table table-light table-hover">';
                      for (j=0; j<dataSources[i].points.length; j++) {
                          dp = dataSources[i].points[j];
                          dshtml += '<tr>';
                          dshtml +=   '<td class="col-sm-3 col-form-label custom-padding-l my-2">'+ dp.name +'</td>';
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
            }
          $("dataSourceList").innerHTML = dshtml;

            var wlhtml = "";
            watchlists = data.watchlists;
            keyTranslations = data.keyTranslations;
            if (watchlists != null){
              for (i=0; i<watchlists.length; i++) {
              if(isUnnamedWatchList(keyTranslations, watchlists[i].name))
                    continue;
                id = watchlists[i].id;
                  wlhtml += '<label class="text-center w-50 fs-6" for="wllist'+ id +'"> '+ watchlists[i].name +'</label><br/>';
                  wlhtml += '<div style="margin-left:25px;" id="wldiv'+ id +'">';
                    wlhtml +=   '<table cellspacing="0" cellpadding="1" class="table table-light table-hover">';
                        wlhtml += '<tr>';
                        wlhtml +=   '<td>';
                        wlhtml +=     '<input  class="form-check-input my-2 align-middle" type="radio" name="wl'+ id +'" id="wl'+ id +'/0" value="0" checked>';
                        wlhtml +=             '<label class="mx-3" for="wl'+ id +'"><fmt:message key="common.access.none"/></label> ';
                        wlhtml +=     '<input  class="form-check-input my-2 align-middle" type="radio" name="wl'+ id +'" id="wl'+ id +'/1" value="1">';
                        wlhtml +=             '<label class="mx-3" for="wl'+ id +'"><fmt:message key="common.access.read"/></label> ';
                        wlhtml +=     '<input  class="form-check-input my-2 align-middle" type="radio" name="wl'+ id +'" id="wl'+ id +'/2" value="2">';
                        wlhtml +=             '<label class="mx-3" for="wl'+ id +'"><fmt:message key="common.access.set"/></label>';
                        wlhtml +=   '</td>';
                        wlhtml += '</tr>';
                    wlhtml +=   '</table>';
                  wlhtml += '</div>';
                }
            }
            $("watchlistsList").innerHTML = wlhtml;

            var vwhtml = "";
            views = data.views;
            if (views != null){
              for (i=0; i<views.length; i++) {
                id = views[i].id;
                  vwhtml += '<label class="text-center w-50 fs-6" for="vvwist'+ id +'"> '+ views[i].name +'</label><br/>';
                  vwhtml += '<div style="margin-left:25px;" id="vwdiv'+ id +'">';
                    vwhtml +=   '<table cellspacing="0" cellpadding="1" class="table table-light table-hover">';
                        vwhtml += '<tr>';
                        vwhtml +=   '<td>';
                        vwhtml +=     '<input  class="form-check-input my-2 align-middle" type="radio" name="vw'+ id +'" id="vw'+ id +'/0" value="0" checked>';
                        vwhtml +=             '<label class="mx-3" for="vw'+ id +'"><fmt:message key="common.access.none"/></label> ';
                        vwhtml +=     '<input  class="form-check-input my-2 align-middle" type="radio" name="vw'+ id +'" id="vw'+ id +'/1" value="1">';
                        vwhtml +=             '<label class="mx-3" for="vw'+ id +'"><fmt:message key="common.access.read"/></label> ';
                        vwhtml +=     '<input  class="form-check-input my-2 align-middle" type="radio" name="vw'+ id +'" id="vw'+ id +'/2" value="2">';
                        vwhtml +=             '<label class="mx-3" for="vw'+ id +'"><fmt:message key="common.access.set"/></label>';
                        vwhtml +=   '</td>';
                        vwhtml += '</tr>';
                        vwhtml +=   '</table>';
                  vwhtml += '</div>';
                }
            }
          $("viewsList").innerHTML = vwhtml;

        });
    }
    
    function showUserProfile(userProfileId) {
        if (userProfileId == -1)
            hide("deleteButton");
        else
            show("deleteButton");
        if (editingUserProfileId)
            stopImageFader($("u"+ editingUserProfileId +"Img"));
        editingUserProfileId = userProfileId;
        UsersProfilesDwr.getUserProfile(userProfileId, showUserProfileCB);
        startImageFader($("u"+ editingUserProfileId +"Img"));
    }
    
    function showUserProfileCB(userProfile) {
        //show($("deleteButton"));
        show($("userProfileDetails"));
        $set("userProfileName", userProfile.name);

        if (dataSources != null){
          var i, j, dscb, dp;
          for (i=0; i<dataSources.length; i++) {
              dscb = $("ds"+ dataSources[i].id);
              dscb.checked = false;
              dataSourceChange(dscb);
              for (j=0; j<dataSources[i].points.length; j++)
              $set("dp"+ dataSources[i].points[j].id, "0");
          }
	        // Turn on the data sources to which the user has permission.
          for (i=0; i<userProfile.dataSourcePermissions.length; i++) {
              dscb = $("ds"+ userProfile.dataSourcePermissions[i]);
              dscb.checked = true;
              dataSourceChange(dscb);
          }

	        // Update the data point permissions.
        for (i=0; i<userProfile.dataPointPermissions.length; i++)
            $set("dp"+ userProfile.dataPointPermissions[i].dataPointId, userProfile.dataPointPermissions[i].permission);
        }

        if(watchlists != null) {
            for (i=0; i<watchlists.length; i++) {
            if(isUnnamedWatchList(keyTranslations, watchlists[i].name))
              continue;
                $set("wl"+ watchlists[i].id, "0");
            }

            // Update the watchlist permissions.
            for (i=0; i<userProfile.watchlistPermissions.length; i++)
                $set("wl"+ userProfile.watchlistPermissions[i].id, userProfile.watchlistPermissions[i].permission);
        }

        if(views != null) {
            for (i=0; i<views.length; i++) {
                $set("vw"+ views[i].id, "0");
            }
            // Update the view permissions.
            for (i=0; i<userProfile.viewPermissions.length; i++)
                $set("vw"+ userProfile.viewPermissions[i].id, userProfile.viewPermissions[i].permission);
        }
        
        setUserProfileMessage();
        //updateUserProfileImg();
    }
    
    function saveUserProfile() {
		startImageFader($("saveButton"));
      setUserProfileMessage();
        // Create the list of allowed data sources and data point permissions.
        var i, j;
        var dsPermis = new Array();
        var dpPermis = new Array();
        var dpval;
        if (dataSources != null){
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

      //populate watchlist permissions paremeters
        var wlPermis = new Array();
        var wlval;
        if (watchlists != null ){
          for (i=0; i<watchlists.length; i++) {
                if(isUnnamedWatchList(keyTranslations, watchlists[i].name))
                    continue;
        wlval = $get("wl"+ watchlists[i].id);

          if (wlval == "1" || wlval == "2") {
              wlPermis.push({id: watchlists[i].id, permission: parseInt(wlval)});
              }
          }
        }

        //populate view permissions paremeters
        var vwPermis = new Array();
        var vwval;
        if (views != null){
          for (i=0; i<views.length; i++) {
        vwval = $get("vw"+ views[i].id);
                  
              if (vwval == "1" || vwval == "2") {
                vwPermis.push({id: views[i].id, permission: parseInt(vwval)});
              }
          }
        }
        
        UsersProfilesDwr.saveUserAdmin(editingUserProfileId, $get("userProfileName"), dsPermis, dpPermis, wlPermis, vwPermis, saveUserProfileCB);
    }
    
    function saveUserProfileCB(response) {
		stopImageFader($("saveButton"));
        if (response.hasMessages)
            showDwrMessages(response.messages, "genericMessages");
        else if (!adminUser)
            setUserProfileMessage("<fmt:message key="userProfiles.saved"/>");
        else {
            if (editingUserProfileId == <c:out value="<%= Common.NEW_ID %>"/>) 
            {
                stopImageFader($("u"+ editingUserProfileId +"Img"));
                editingUserProfileId = response.data.userProfileId;
                appendUserProfile(editingUserProfileId);
                startImageFader($("u"+ editingUserProfileId +"Img"));
                setUserProfileMessage("<fmt:message key="userProfiles.added"/>");
                show($("deleteButton"));
            } else {
                setUserProfileMessage("<fmt:message key="userProfiles.saved"/>");
                stopImageFader($("u"+ editingUserProfileId +"Img"));
          }
            UsersProfilesDwr.getUserProfile(editingUserProfileId, updateUserProfile)
        }
    }
    
    function setUserProfileMessage(message) {
        if (message)
            $set("userProfileMessage", message);
        else {
            $set("userProfileMessage");
            hideContextualMessages("userProfileDetails");
            hideGenericMessages("genericMessages");
        }
    }
    
    function appendUserProfile(userProfileId) {
        createFromTemplate("u_TEMPLATE_", userProfileId, "userProfileTable");
    }
    
    function updateUserProfile(userProfile) {
        $("u"+ userProfile.id +"UserProfileName").innerHTML = userProfile.name;
        setUserImg(true, userProfile.disabled, $("u"+ userProfile.id +"Img"));
        console.log("u"+ editingUserProfileId +"Img")
    }

    /*function updateUserProfileImg() {
        setUserImg(true, $get("disabled"), $("userImg"));
    }*/

    function dataSourceChange(dscb) {
        display("dsps"+ dscb.id.substring(2), !dscb.checked);
    }
    
    function deleteUserProfile() {
        if (confirm("<sst:i18n key="userProfiles.deleteConfirm" escapeDQuotes="true"/>")) {
          var profileId = editingUserProfileId;
            startImageFader("deleteButton");
            UsersProfilesDwr.deleteUsersProfile(profileId, function(response) {
                stopImageFader("deleteButton");
                
                if (response.hasMessages) {
                  alert(response.messages[0].genericMessage);
              }
                stopImageFader("u"+ profileId +"Img");
                $("userProfileTable").removeChild($("u"+ profileId));
                hide("userProfileDetails");
                editingUserProfileId = null;
              
            });
        }
    }

    function isUnnamedWatchList(keyTranslations, wl) {
      if (keyTranslations) {
        return keyTranslations.includes(wl); // skip unnamed lists
      }
      return false;
    }
  </script>
  
  <table class="subPageHeader container">
    <tr>
      <td valign="top" id="userProfileList" style="display:none;">
        <div class="left-menu">
        <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
          <span class="smallTitle"><fmt:message key="userProfiles.title"/></span>
        </div>
        <div>
          <i class="bi bi-person-plus-fill text-blue-add align-middle ms-3 fs-5" onclick="showUserProfile(${applicationScope['constants.Common.NEW_ID']})"
                  title="<fmt:message key='userProfiles.add'/>" id="u${applicationScope['constants.Common.NEW_ID']}Img"></i>
                <%-- <span style="font-size: 16px;">
                  <sst:i18n key='userProfiles.add' escapeDQuotes='true'/>
                </span> --%>
        </div>
        </div>
        <div class="top-row-d-flex justify-content-between container py-2 box mb-3">
          <table id="userProfileTable">
            <tbody id="u_TEMPLATE_" onclick="showUserProfile(getMangoId(this))" class="ptr" style="display:none;"><tr>
              <td>
                <i id="u_TEMPLATE_Img" class="bi bi-person-circle" title="<fmt:message key='userProfile.user'/>"></i>
              </td>
              <td class="text-uppercase fs-7" id="u_TEMPLATE_UserProfileName"></td>
            </tr></tbody>
          </table>
        </div>
        </div>
      </td>
      
      <td valign="top" style="display:none;" id="userProfileDetails">
        <div class="right-box">
          <div class="d-flex justify-content-between container py-2 box mb-3">
            <div>
              <span class="smallTitle"><i id="userImg" class="bi bi-person-vcard me-2 fs-5" title="<fmt:message key='userProfiles.details'/>"></i>
              <fmt:message key="userProfiles.details"/></span>
            </div>
            <div class="d-flex justify-content-between align-items-center">
              <i id="saveButton" class="bi bi-floppy2-fill text-blue-add  me-2 fs-5" onclick="saveUserProfile();" title="<fmt:message key='common.save'/>"></i>
                <span style="font-size: 16px;">
                <sst:i18n key='common.save' escapeDQuotes='true'/>
                </span>
              <i id="deleteButton" class="bi bi-trash  text-danger ms-2 me-2 fs-5" onclick="deleteUserProfile();" title="<fmt:message key='common.delete'/>" style="display:none;">
                <span style="font-size: 16px; color: var(--slts-color-primary-text);">
                <sst:i18n key='common.delete' escapeDQuotes='true'/>
                </span></i>
            </div>
          </div>

          <div class="m-4">
          <table><tbody id="genericMessages"></tbody></table>
          
          <table class="w-100">
            <tr>
              <td colspan="2" id="userProfileMessage" class="formError"></td>
            </tr>
            <tr id="userProfileNameRow" style="display:none;">
              <td class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="userProfiles.name"/></td>
              <td class="formField"><input class="form-control form-control-sm my-2" id="userProfileName" type="text"/></td>
            </tr>
            <tbody id="dataSources" style="display:none;">
              <tr><td class="m-4" colspan="2"><hr class="border border-secondary w-100 my-4"/></td></tr>
              <tr class="m-5" id="dataSources">
                <td class="text-center w-5 fs-6"><fmt:message key="userProfiles.dataSources"/></td>
                <td class="formField" id="dataSourceList"></td>
              </tr>
              <tr><td class="m-4" colspan="2"><hr class="border border-secondary w-100 my-4"/></td></tr>
              <tr id="watchlists">
                <td class="text-center w-5 fs-6"><fmt:message key="header.watchLists"/></td>
                <td class="formField" id="watchlistsList"></td>
              </tr>
              <tr><td class="m-4" colspan="2"><hr class="border border-secondary w-100 my-4"/></td></tr>
              <tr id="views">
                <td class="text-center w-5 fs-6"><fmt:message key="views.title"/></td>
                <td class="formField" id="viewsList"></td>
              </tr>
            </tbody>
          </table>
          </div>
        </div>
      </td>
    </tr>
  </table>

</tag:page>
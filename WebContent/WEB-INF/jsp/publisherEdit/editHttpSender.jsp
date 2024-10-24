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
<%@page import="com.serotonin.mango.vo.publish.httpSender.HttpSenderVO"%>
<%@ include file="/WEB-INF/jsp/include/tech.jsp" %>
<script type="text/javascript">
  var staticHeaderList;
  var staticParameterList = new Array();
  var allPoints = new Array();  
  var selectedPoints = new Array();  
  
  function init() {
      PublisherEditDwr.initSender(initCB);
      initInputSelect();
  }
  dojo.addOnLoad(init);

  function initCB(response) {
      var i;
      var list = response.data.allPoints;
      for (var i=0; i<list.length; i++)
          allPoints[allPoints.length] = {
                  id: list[i].id, name: list[i].extendedName, enabled: list[i].enabled, type: list[i].dataTypeMessage};

      staticHeaderList = new Array();
      list = response.data.publisher.staticHeaders;
      for (i=0; i<list.length; i++)
          staticHeaderList[staticHeaderList.length] = {key: list[i].key, value: list[i].value};
      refreshStaticHeaderList();
      
      list = response.data.publisher.staticParameters;
      for (i=0; i<list.length; i++)
          staticParameterList[staticParameterList.length] = {key: list[i].key, value: list[i].value};
      refreshStaticParameterList();
      
      list = response.data.publisher.points;
      for (i=0; i<list.length; i++)
          addToSelectedArray(list[i].dataPointId, list[i].parameterName, list[i].includeTimestamp);
      refreshSelectedPoints();
      PublisherEditDwr.getBasicCredentials(staticHeaderList, setCredentials);
      PublisherEditDwr.getIsUseJSON(setUseJSON);
  }

  function initStaticHeaders(response) {
    staticHeaderList = new Array();
    var i;
    var list = response.data.staticHeaders;
    for (i=0; i<list.length; i++)
      staticHeaderList[staticHeaderList.length] = {key: list[i].key, value: list[i].value};
    refreshStaticHeaderList();
    PublisherEditDwr.getBasicCredentials(staticHeaderList, setCredentials);
  }

  function setCredentials(credentials) {
      $set("username", credentials[0]);
      $set("password", credentials[1]);
  }

  function setUseJSON(useJSON) {
      $set("useJSON", useJSON);
  }
  
  function addStaticHeader() {
      var key = $get("sheaderKey");
      var value = $get("sheaderValue");
      
      if (!key || key.trim().length == 0) {
          alert("<fmt:message key="publisherEdit.httpSender.keyRequired"/>");
          return;
      }
      
      for (var i=0; i<staticHeaderList.length; i++) {
          if (staticHeaderList[i].key == key) {
              alert("<fmt:message key="publisherEdit.httpSender.keyExists"/>: '"+ key +"'");
              return;
          }
      }
      
      staticHeaderList[staticHeaderList.length] = {key: key, value: value};
      staticHeaderList.sort();
      refreshStaticHeaderList();
      hideHttpSenderTest();
  }
  
  function removeStaticHeader(index) {
      if (staticHeaderList[index].key == "Authorization") {
        $set("username", "");
        $set("password", "");
      }
      staticHeaderList.splice(index, 1);
      refreshStaticHeaderList();
      hideHttpSenderTest();
  }
  
  function refreshStaticHeaderList() {
      dwr.util.removeAllRows("staticHeaderList");
      if (staticHeaderList.length == 0)
          show("noStaticHeadersMsg");
      else {
          hide("noStaticHeadersMsg");
          dwr.util.addRows("staticHeaderList", staticHeaderList, [
                  function(data) { return data.key +"="+ data.value; },
                  function(data, options) {
                      return "<i class='bi bi-trash text-danger align-middle me-2 fs-5' title='<fmt:message key="publisherEdit.httpSender.removeHeader"/>' "+
                              "onclick='removeStaticHeader("+ options.rowIndex + ");'></i>";
                  }
                  ], null);
      }
  }
  
  function addStaticParameter() {
      var key = $get("sparamKey");
      var value = $get("sparamValue");
      
      if (!key || key.trim().length == 0) {
          alert("<fmt:message key="publisherEdit.httpSender.keyRequired"/>");
          return;
      }
      
      for (var i=0; i<staticParameterList.length; i++) {
          if (staticParameterList[i].key == key) {
              alert("<fmt:message key="publisherEdit.httpSender.keyExists"/>: '"+ key +"'");
              return;
          }
      }
      
      staticParameterList[staticParameterList.length] = {key: key, value: value};
      staticParameterList.sort();
      refreshStaticParameterList();
      hideHttpSenderTest();
  }
  
  function removeStaticParameter(index) {
      staticParameterList.splice(index, 1);
      refreshStaticParameterList();
      hideHttpSenderTest();
  }
  
  function refreshStaticParameterList() {
      dwr.util.removeAllRows("staticParameterList");
      if (staticParameterList.length == 0)
          show("noStaticParametersMsg");
      else {
          hide("noStaticParametersMsg");
          dwr.util.addRows("staticParameterList", staticParameterList, [
                  function(data) { return data.key +"="+ data.value; },
                  function(data, options) {
                      return "<i class='bi bi-trash text-danger align-middle me-2 fs-5' title='<fmt:message key="publisherEdit.httpSender.removeParam"/>' "+
                              "onclick='removeStaticParameter("+ options.rowIndex + ");'></i>";
                  }
                  ], null);
      }
  }
  
  function selectPoint() {
      var pointId = $get("availablePoints");
      addToSelectedArray(pointId, null, true);
      refreshSelectedPoints();
  }
  
  function addToSelectedArray(pointId, parameterName, includeTimestamp) {
      var data = getElement(allPoints, pointId);
      
      if (parameterName == null)
          parameterName = data.name;
      
      if (data) {
          // Missing names imply that the point was deleted, so ignore.
          selectedPoints[selectedPoints.length] = {
              id : pointId,
              pointName : data.name,
              enabled : data.enabled,
              pointType : data.type,
              parameterName: parameterName,
              includeTimestamp: includeTimestamp
          };
      }
  }
  
  function removeFromSelectedPoints(pointId) {
      removeElement(selectedPoints, pointId);
      refreshSelectedPoints();
  }
  
  function refreshSelectedPoints() {
      dwr.util.removeAllRows("selectedPoints");
      if (selectedPoints.length == 0)
          show("selectedPointsEmpty");
      else {
          hide("selectedPointsEmpty");
          dwr.util.addRows("selectedPoints", selectedPoints,
              [
                  function(data) { return data.pointName; },
                  function(data) { return "<i class='"+ (data.enabled ? "bi bi-puzzle-fill text-success align-middle me-2 fs-5" : "bi bi-puzzle-fill text-danger align-middle me-2 fs-5") +"'></i>"; },
                  function(data) { return data.pointType; },
                  function(data) {
                          return "<input class='form-control form-control-sm' type='text' value='"+ data.parameterName +"' "+
                                  "onblur='updateParameterName("+ data.id +", this.value)'/>";
                  },
                  function(data) {
                          return "<input type='checkbox' class='form-check-input custom-checkbox' "+ (data.includeTimestamp ? "checked='checked' " : "") +
                                  "onclick='updateIncludeTimestamp("+ data.id +", this.checked)'/>";
                  },
                  function(data) { 
                          return "<i class='bi bi-trash text-danger align-middle me-2 fs-5' "+
                                  "onclick='removeFromSelectedPoints("+ data.id +")'></i>";
                  }
              ],
              {
                  rowCreator: function(options) {
                      var tr = document.createElement("tr");
                      tr.className = "rowTable"+ (options.rowIndex % 2 == 0 ? "" : "Alt");
                      return tr;
                  },
                  cellCreator: function(options) {
                      var td = document.createElement("td");
                      if (options.cellNum == 1 || options.cellNum == 4)
                          td.align = "center";
                      return td;
                  } 
              });
      }
      refreshAvailablePoints();
  }
  
  function refreshAvailablePoints() {
      dwr.util.removeAllOptions("availablePoints");
      var availPoints = new Array();
      for (var i=0; i<allPoints.length; i++) {
          var found = false;
          for (var j=0; j<selectedPoints.length; j++) {
              if (selectedPoints[j].id == allPoints[i].id) {
                  found = true;
                  break;
              }
          }
          
          if (!found)
              availPoints[availPoints.length] = allPoints[i];
      }
      dwr.util.addOptions("availablePoints", availPoints, "id", "name");
  }
  
  function updateParameterName(pointId, parameterName) {
      updateElement(selectedPoints, pointId, "parameterName", parameterName);
  }
  
  function updateIncludeTimestamp(pointId, includeTimestamp) {
      updateElement(selectedPoints, pointId, "includeTimestamp", includeTimestamp);
  }
  
  function savePublisherImpl(name, xid, enabled, cacheWarningSize, changesOnly, sendSnapshot, snapshotSendPeriods,
          snapshotSendPeriodType) {
      // Clear messages.
      hide("urlMsg");
      hide("pointsMsg");
      
      var points = new Array();
      for (var i=0; i<selectedPoints.length; i++)
          points[points.length] = {dataPointId: selectedPoints[i].id, parameterName: selectedPoints[i].parameterName,
                  includeTimestamp: selectedPoints[i].includeTimestamp};

      updateStaticHeadersList();

      PublisherEditDwr.saveHttpSender(name, xid, enabled, points, $get("url"), $get("usePost") == "true", 
    		  staticHeaderList, staticParameterList, cacheWarningSize, changesOnly, $get("raiseResultWarning"),
    		  $get("dateFormat"), sendSnapshot, snapshotSendPeriods, snapshotSendPeriodType,
              $get("username"), $get("password"), $get("useJSON"), saveHttpSenderCB);
  }

  function saveHttpSenderCB(response) {
    savePublisherCB(response);
    PublisherEditDwr.updateHttpSenderStaticHeaders(initStaticHeaders);
  }
  
  function httpSendTest() {
      showMessage("httpSendTestMessage", "<fmt:message key="publisherEdit.httpSender.sending"/>");
      showMessage("httpSendTestData");
      httpSendTestButtons(true);
      PublisherEditDwr.httpSenderTest(httpSendTestCB);
  }
  
  function httpSendTestButtons(sending) {
      setDisabled("httpSendTestBtn", sending);
      setDisabled("httpSendTestCancelBtn", !sending);
  }
  
  function httpSendTestCB() {
      setTimeout(httpSendTestUpdate, 2000);
  }
  
  function httpSendTestUpdate() {
      PublisherEditDwr.httpSenderTestUpdate(httpSendTestUpdateCB);
  }
  
  function httpSendTestUpdateCB(result) {
      if (result || result == "") {
          showMessage("httpSendTestMessage");
          if (result)
              showMessage("httpSendTestData", result);
          else
              showMessage("httpSendTestData", "<fmt:message key="publisherEdit.httpSender.noResponseData"/>");
          httpSendTestButtons(false);
      }
      else
          httpSendTestCB();
  }
  
  function httpSendTestCancel() {
      PublisherEditDwr.cancelTestingUtility(httpSendTestCancelCB);
  }
  
  function httpSendTestCancelCB() {
      httpSendTestButtons(false);
      showMessage("httpSendTestMessage", "<fmt:message key="common.cancelled"/>");
  }

  function removeAuthFromStaticHeaders() {
    staticHeaderList = staticHeaderList.filter(header => header.key != 'Authorization');
  }

  function updateStaticHeadersList() {
    if (!$get("username") || !$get("password")) {
      removeAuthFromStaticHeaders();
      refreshStaticHeaderList();
    }
  }

  function initInputSelect() {
      initHttpSenderTest();
      var inputs = document.querySelectorAll('#publisherEditor input');
      var selects = document.querySelectorAll('#publisherEditor select');
      addChangeEvent(inputs);
      addChangeEvent(selects);
  }

  function addChangeEvent(tab) {
      if(tab && tab.forEach) {
        tab.forEach(function(currentValue, currentIndex, listObj) {
            if(currentValue.type && currentValue.type != 'button'
            && currentValue.id && currentValue.id != 'sheaderKey'
            && currentValue.id != 'sparamKey'
            && currentValue.id != 'sheaderValue'
            && currentValue.id != 'sparamValue')
              currentValue.addEventListener('change', function() { hideHttpSenderTest(); }, false);
            }, '');
      }
  }

  function initHttpSenderTest() {
    if(${not empty publisher and publisher.id != -1})
        showHttpSenderTest();
    else
        hideHttpSenderTest();
  }

  function hideHttpSenderTest() {
      document.getElementById("httpSenderTest").style.visibility = "hidden";
  }

  function showHttpSenderTest() {
      document.getElementById("httpSenderTest").style.visibility = "visible";
  }
</script>

<table id="publisherEditor" class="container">
  <div>
    <td class="top w-100">
      <div class="right-box my-3">
        <table class="w-100">
          <div class="container">
          <div class="col-12 m-3">
            <div class="smallTitle">
              <fmt:message key="publisherEdit.httpSender.props"/>
              <tag:help id="httpSenderPublishing"/>
            </div>
          </div>
          </div>
          
          <div class="container">
            <div class="row">
                <div class="col-lg-6 col-12">

                  <div class="form-group row">
                    <label for="usePost" class="col-sm-3 col-form-label custom-padding-l"><fmt:message key="publisherEdit.httpSender.method"/></label>
                    <div class="col-sm-8 my-2">
                    <select id="usePost" class="form-select form-select-sm my-2" value="${publisher.usePost}">
                      <option value="false">GET</option>
                      <option value="true">POST</option>
                    </select>
                    </div>
                  </div>

                  <div class="form-group row">
                    <label for="useJSON" class="col-sm-3 col-form-label custom-padding-l"><fmt:message key="publisherEdit.httpSender.useJSON"/></label>
                    <div class="col-sm-5 my-2">
                    <input type="checkbox" class="form-check-input custom-checkbox" id="useJSON"/>
                    </div>
                  </div>

                  <div class="form-group row">
                    <label for="url" class="col-sm-3 col-form-label custom-padding-l"><fmt:message key="publisherEdit.httpSender.url"/></label>
                    <div class="col-sm-8 my-2">
                    <input class="form-control form-control-sm" type="text" id="url" value="${publisher.url}"/>
                    <div id="urlMsg" class="formError" style="display:none;"></div>
                    </div>
                  </div>
          
                  <div class="form-group row">
                    <label for="raiseResultWarning" class="col-sm-3 col-form-label custom-padding-l"><fmt:message key="publisherEdit.httpSender.raiseResultWarning"/></label>
                    <div class="col-sm-5 my-2">
                    <input type="checkbox" class="form-check-input custom-checkbox" id="raiseResultWarning" selectedValue="${publisher.raiseResultWarning}"/>
                    </div>
                  </div>

                  <div class="form-group row">
                    <label for="dateFormat" class="col-sm-3 col-form-label custom-padding-l"><fmt:message key="publisherEdit.httpSender.dateFormat"/></label>
                    <div class="col-sm-8 my-2">
                    <select class="form-select form-select-sm my-2" id="dateFormat" value="${publisher.dateFormat}">
                      <option value="<%= Integer.toString(HttpSenderVO.DATE_FORMAT_BASIC) %>"><fmt:message key="publisherEdit.httpSender.dateFormat.basic"/></option>
                      <option value="<%= Integer.toString(HttpSenderVO.DATE_FORMAT_TZ) %>"><fmt:message key="publisherEdit.httpSender.dateFormat.tz"/></option>
                      <option value="<%= Integer.toString(HttpSenderVO.DATE_FORMAT_UTC) %>"><fmt:message key="publisherEdit.httpSender.dateFormat.utc"/></option>
                    </select>
                    </div>
                  </div>

                  <tr><div class="m-4" colspan="2"><hr class="border border-secondary w-100 my-4"/></div></tr>

          </div>
                
          <div class="col-lg-6 col-12">

                <div class="form-group row">
                  <label class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="publisherEdit.httpSender.credentials"/></label>
                  <div class="col-sm-10">
                  <div class="form-group">
                    <label for="username" class="form-label"><fmt:message key="publisherEdit.httpSender.username"/></label>
                    <input class="form-control form-control-sm" type="text" id="username"/>
                  </div>
                  <div class="form-group">
                    <label for="password" class="form-label"><fmt:message key="publisherEdit.httpSender.password"/></label>
                    <input class="form-control form-control-sm" type="password" id="password"/>
                  </div>
                  </div>
                </div>

                <tr><div class="m-4" colspan="2"><hr class="border border-secondary w-100 my-4"/></div></tr>

                <tr>
                  <td class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="publisherEdit.httpSender.staticHeaders"/></td>
                  <td class="formField">
                    <fmt:message key="publisherEdit.httpSender.headerKey"/> <input class="form-control form-control-sm" type="text" id="sheaderKey"/>
                    <fmt:message key="publisherEdit.httpSender.headerValue"/> <input class="form-control form-control-sm" type="text" id="sheaderValue"/>
                    <i class="bi bi-plus-circle-fill text-success align-middle me-2 fs-5" title="<fmt:message key='publisherEdit.httpSender.addStaticHeader'/>" onclick="addStaticHeader()"></i>
                    <table  class="table table-light table-hover align-middle">
                      <tr id="noStaticHeadersMsg" style="display:none"><td><fmt:message key="publisherEdit.httpSender.noStaticHeaders"/></td></tr>
                      <tbody id="staticHeaderList"></tbody>
                    </table>
                  </td>
                </tr>
                
                <tr>
                  <td class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="publisherEdit.httpSender.staticParams"/></td>
                  <td class="formField">
                    <fmt:message key="publisherEdit.httpSender.paramKey"/> <input class="form-control form-control-sm" type="text" id="sparamKey"/>
                    <fmt:message key="publisherEdit.httpSender.paramValue"/> <input class="form-control form-control-sm" type="text" id="sparamValue"/>
                    <i class="bi bi-plus-circle-fill text-success align-middle me-2 fs-5" title="<fmt:message key='publisherEdit.httpSender.addStaticParam'/>" onclick="addStaticParameter()"></i>
                    <table  class="table table-light table-hover align-middle">
                      <tr id="noStaticParametersMsg" style="display:none"><td>
                      <fmt:message key="publisherEdit.httpSender.noStaticParams"/></td>
                      </tr>
                      <tbody id="staticParameterList"></tbody>
                    </table>
                  </td>
                </tr>
                
          </div>

          <td class="formLabelRequired">
              <table>
                
              </table>
          </td>

          <td valign="top" class="formField">
            <div id="httpSenderTest" class="right-box w-100">
              <table>
                <tr><td class="smallTitle"><fmt:message key="publisherEdit.httpSender.sendTest"/></td></tr>
                <tr>
                  <td align="center">
                      <button  id="httpSendTestBtn" type="button" class="btn btn-primary custom-btn-blue m-2" name="httpSendTestBtn" onclick="httpSendTest()">
                      <fmt:message key="publisherEdit.httpSender.sendStaticParams"/></button>
                      <button  id="httpSendTestCancelBtn" type="button" class="btn btn-primary custom-btn-blue m-2" name="httpSendTestCancelBtn" onclick="httpSendTestCancel()">
                      <fmt:message key="publisherEdit.httpSender.cancel"/></button>
                    </td>
                </tr>
                <tr><td id="httpSendTestMessage" class="formError"></td></tr>
                <tr><td class="formField"><pre id="httpSendTestData"></pre></td></tr>
              </table>
            </div>
          </td>

        </table>
      </div>
    </td>
  </div>
</table>

<%-- <table cellpadding="0" cellspacing="0"><tr><td>
      <td valign="top" class="right-box w-100">
      <tr><div class="m-4" colspan="2"><hr class="border border-secondary w-100 my-4"/></div></tr>
        <div id="httpSenderTest" class="right-box w-100">
          <table>
            <tr><td class="smallTitle"><fmt:message key="publisherEdit.httpSender.sendTest"/></td></tr>
            <tr>
              <td align="center">
                <button  id="httpSendTestBtn" type="button" class="btn btn-primary custom-btn-blue mx-2" name="httpSendTestBtn" onclick="httpSendTest()">
                <fmt:message key="publisherEdit.httpSender.sendStaticParams"/></button>
                <button  id="httpSendTestCancelBtn" type="button" class="btn btn-primary custom-btn-blue mx-2" name="httpSendTestCancelBtn" onclick="httpSendTestCancel()">
                <fmt:message key="publisherEdit.httpSender.cancel"/></button>
              </td>
            </tr>
            <tr><td id="httpSendTestMessage" class="formError"></td></tr>
            <tr><td class="formField"><pre id="httpSendTestData"></pre></td></tr>
          </table>
        </div>
      </td>
</td></tr></table> --%>

<table cellpadding="0" cellspacing="0"><tr><td>
  <div class="right-box my-3">
    <table class="w-100">
      <tr>
        <td class="smallTitle"><fmt:message key="publisherEdit.points"/></td>
        <td align="right">
          <select class="form-select form-select-sm my-2" id="availablePoints"></select>
          <i class="bi bi-plus-circle-fill text-success align-middle me-2 fs-5" onclick="selectPoint()"></i>
        </td>
      </tr>
    </table>
    
    <table cellspacing="1" cellpadding="0" class="table table-light table-hover align-middle">
      <tr class="rowHeader">
        <td><fmt:message key="publisherEdit.point.name"/></td>
        <td><fmt:message key="publisherEdit.point.status"/></td>
        <td><fmt:message key="publisherEdit.point.type"/></td>
        <td><fmt:message key="publisherEdit.httpSender.point.param"/></td>
        <td><fmt:message key="publisherEdit.httpSender.point.timestamp"/></td>
        <td></td>
      </tr>
      <tbody id="selectedPointsEmpty" style="display:none;"><tr><td colspan="6"><fmt:message key="publisherEdit.noPoints"/></td></tr></tbody>
      <tbody id="selectedPoints"></tbody>
    </table>
    <div id="pointsMsg" class="formError" style="display:none;"></div>
  </div>
</td></tr></table>
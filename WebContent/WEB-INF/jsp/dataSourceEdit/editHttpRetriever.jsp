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
<%@page import="com.serotonin.mango.DataTypes"%>
<link href="resources/js-ui/app/css/chunk-vendors.css" rel="stylesheet" type="text/css">
<%-- <link href="resources/js-ui/app/css/app.css" rel="stylesheet" type="text/css"> --%>

<script type="text/javascript">

  // when end of load get data from model and set in editHttpRetriver

  // share data old ui and new ui in vuejs
  var staticHeaderList;

  var editDSNewUI = {
    id: ${dataSource.id},
    stop: ${dataSource.stop},
    reactivation: {
      sleep: ${dataSource.reactivation.sleep},
      type: ${dataSource.reactivation.type}, // 0-"Minute" 1-"Hour", 2-"Day"
      value: ${dataSource.reactivation.value}
    }
  }

  function initImpl() {
    DataSourceEditDwr.initHttpRetriever(initRetriever);
  }

  function initRetriever(response) {
    staticHeaderList = new Array();
    var i;
    var list = response.data.staticHeaders;
    for (i=0; i<list.length; i++)
      staticHeaderList[staticHeaderList.length] = {key: list[i].key, value: list[i].value};
    refreshStaticHeaderList();
    DataSourceEditDwr.getBasicCredentials(list, setCredentials);
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
  }

  function removeStaticHeader(index) {
    if (staticHeaderList[index].key == "Authorization") {
      $set("username", "");
      $set("password", "");
    }
    staticHeaderList.splice(index, 1);
    refreshStaticHeaderList();
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
          return "<i class='bi bi-trash text-danger align-middle ms-2 fs-5' title='<fmt:message key="dsEdit.httpRetriever.removeHeader"/>' "+ "onclick='removeStaticHeader("+ options.rowIndex + ");'></i>";
        }
      ], null);
    }
  }

  function setCredentials(credentials) {
    $set("username", credentials[0]);
    $set("password", credentials[1]);
  }

  function testValueParams() {
      startImageFader("valueTestImg", true);
      hide("valueTestRow");
      DataSourceEditDwr.testHttpRetrieverValueParams($get("url"), $get("timeoutSeconds"), $get("retries"),
              $get("valueRegex"), $get("dataTypeId"), $get("valueFormat"), staticHeaderList, testValueParamsCB);
  }
  
  function testValueParamsCB(result) {
      stopImageFader("valueTestImg");
      show("valueTestRow");
      $set("valueTestResult", encodeHtml(result));
  }

  function testTimeParams() {
      startImageFader("timeTestImg", true);
      hide("timeTestRow");
      DataSourceEditDwr.testHttpRetrieverTimeParams($get("url"), $get("timeoutSeconds"), $get("retries"),
              $get("timeRegex"), $get("timeFormat"), staticHeaderList, testTimeParamsCB);
  }
  
  function testTimeParamsCB(result) {
      stopImageFader("timeTestImg");
      show("timeTestRow");
      $set("timeTestResult", result);
  }

  function saveDataSourceImplOld(){
    updateStaticHeadersList();
    DataSourceEditDwr.saveHttpRetrieverDataSource($get("dataSourceName"), $get("dataSourceXid"),
                $get("updatePeriods"), $get("updatePeriodType"), $get("url"), $get("timeoutSeconds"), $get("retries"),
                $get("stop"), $get("username"), $get("password"), staticHeaderList,
                saveHttpRetrieverDataSourceCB);
  }

  function saveDataSourceImpl() {
      updateStaticHeadersList();
      DataSourceEditDwr.saveHttpRetrieverDataSourceWithReactivationOptions(
                  $get("dataSourceName"),
                  $get("dataSourceXid"),
                  $get("updatePeriods"),
                  $get("updatePeriodType"),
                  $get("url"),
                  $get("timeoutSeconds"),
                  $get("retries"),
                  editDSNewUI.stop,
                  editDSNewUI.reactivation.sleep,
                  editDSNewUI.reactivation.type,
                  editDSNewUI.reactivation.value,
                  $get("username"),
                  $get("password"),
                  staticHeaderList,
                  saveHttpRetrieverDataSourceCB
      );
  }

  function saveHttpRetrieverDataSourceCB(response) {
    saveDataSourceCB(response);
    DataSourceEditDwr.initHttpRetriever(initRetriever);
  }

  function openURL() {
    var url = $get('url');
    if ($get("username") && $get("password")) {
      var urlParts = url.split("://", 2);
      if (urlParts.length === 2) {
        url = urlParts[0] + "://" + $get("username") + ":" + $get("password") + "@" + urlParts[1];
      }
    }
    window.open(url, 'httpRetrieverTarget');
  }

  function appendPointListColumnFunctions(pointListColumnHeaders, pointListColumnFunctions) {
      pointListColumnHeaders[pointListColumnHeaders.length] = "<fmt:message key="dsEdit.httpRetriever.regex"/>";
      pointListColumnFunctions[pointListColumnFunctions.length] =
          function(p) { return encodeHtml(p.pointLocator.valueRegex); };
  }
  
  function editPointCBImpl(locator) {
      $set("valueRegex", locator.valueRegex);
      $set("ignoreIfMissing", locator.ignoreIfMissing);
      $set("dataTypeId", locator.dataTypeId);
      $set("valueFormat", locator.valueFormat);
      $set("timeRegex", locator.timeRegex);
      $set("timeFormat", locator.timeFormat);
      
      dataTypeChanged();
      timeRegexKU();
  }
  
  function savePointImpl(locator) {
      delete locator.settable;
      
      locator.valueRegex = $get("valueRegex");
      locator.ignoreIfMissing = $get("ignoreIfMissing");
      locator.dataTypeId = $get("dataTypeId");
      locator.valueFormat = $get("valueFormat");
      locator.timeRegex = $get("timeRegex");
      locator.timeFormat = $get("timeFormat");
      
      DataSourceEditDwr.saveHttpRetrieverPointLocator(currentPoint.id, $get("xid"), $get("name"), locator, savePointCB);
  }
  
  function dataTypeChanged() {
      var dataTypeId = $get("dataTypeId");
      if (dataTypeId == <%= DataTypes.BINARY %>) {
          show("valueFormatRow");
          hide("numberFormatHelp");
          $set("valueFormatLabel", "<fmt:message key="dsEdit.httpRetriever.binaryZeroValue"/>");
      }
      else if (dataTypeId == <%= DataTypes.NUMERIC %>) {
          show("valueFormatRow");
          show("numberFormatHelp");
          $set("valueFormatLabel", "<fmt:message key="dsEdit.httpRetriever.numberFormat"/>");
      }
      else {
          hide("numberFormatHelp");
          hide("valueFormatRow");
      }
  }
  
  function timeRegexKU() {
      var timeRegexLen = $get("timeRegex").trim().length;
      display("timeFormatRow", timeRegexLen > 0);
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

  //função para adicionar classes aos selects estilo bootstrap
  function addClassToSelects() {
  var selectGroups = [
    {
    ids: ["deviceCode", "accessMode"],
    classes: ["w-75", "form-select", "form-select-sm", "my-2"]
    },
    {
    ids: ["updatePeriodType"],
    classes: ["w-25", "form-select", "form-select-sm", "my-2"]
    },
    {
    ids: ["alarmLevel1", "alarmLevel2", "alarmLevel3", "alarmLevel4"],
    classes: ["w-100", "form-select", "form-select-sm", "my-2"]
    }
  ];

  selectGroups.forEach(function(group) {
    group.ids.forEach(function(id) {
    var selectElement = document.getElementById(id);
    if (selectElement) {
      selectElement.classList.add(...group.classes);
    }
    });
  });
  }

  // Chama a função após a página ser carregada
  window.onload = addClassToSelects;
</script>

<c:set var="dsDesc"><fmt:message key="dsEdit.httpRetriever.desc"/></c:set>
<c:set var="dsHelpId" value="httpRetrieverDS"/>
<%@ include file="/WEB-INF/jsp/dataSourceEdit/dsHead.jspf" %>
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.updatePeriod"/></td>
          <td class="d-flex align-items-center justify-content-start">
            <input class="w-25 form-control form-control-sm me-2" type="text" id="updatePeriods" value="${dataSource.updatePeriods}" class="formShort"/>
            <sst:select id="updatePeriodType" value="${dataSource.updatePeriodType}">
              <tag:timePeriodOptions sst="true" ms="true" s="true" min="true" h="true"/>
            </sst:select>
          </td>
        </tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.httpRetriever.url"/></td>
          <td class="d-flex align-items-center justify-content-start">
            <input id="url" class="w-75 form-control form-control-sm my-2" type="text" value="${dataSource.url}" class="formLong"/>
            <i class="bi bi-caret-right-square-fill text-blue-add align-middle ms-3 fs-5" title="<fmt:message key='dsEdit.httpRetriever.openUrl'/>"  onclick="openURL()"></i>
            <%-- <tag:img png="bullet_go" onclick="openURL()" title="dsEdit.httpRetriever.openUrl"/> --%>
          </td>
        </tr>

        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.httpRetriever.credentials"/></td>
          <td class="formField">
            <fmt:message key="dsEdit.httpRetriever.username"/> <input class="w-25 form-control form-control-sm my-2" type="text" id="username" class="formShort"/>
            <fmt:message key="dsEdit.httpRetriever.password"/> <input class="w-25 form-control form-control-sm my-2" type="password" id="password" class="formShort"/>
          </td>
        </tr>

        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="publisherEdit.httpSender.staticHeaders"/></td>
          <td class="formField">
            <fmt:message key="publisherEdit.httpSender.headerKey"/> <input class="w-75 form-control form-control-sm my-2" type="text" id="sheaderKey" class="formShort"/>
            <fmt:message key="publisherEdit.httpSender.headerValue"/> <input class="w-75 form-control form-control-sm my-2" type="text" id="sheaderValue" class="formShort"/>
            <i class="bi bi-plus-circle-fill text-blue-add align-middle ms-3 fs-5" title="<fmt:message key='publisherEdit.httpSender.addStaticHeader'/>"  onclick="addStaticHeader()"></i>
            <table class="fs-6 text-center table table-light table-hover my-2">
              <tr id="noStaticHeadersMsg" style="display:none"><td><fmt:message key="publisherEdit.httpSender.noStaticHeaders"/></td></tr>
              <tbody id="staticHeaderList"></tbody>
            </table>
          </td>
        </tr>

        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.httpRetriever.timeout"/></td>
          <td class="formField"><input id="timeoutSeconds" class="w-25 form-control form-control-sm my-2" type="text" value="${dataSource.timeoutSeconds}"/></td>
        </tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.httpRetriever.retries"/></td>
          <td class="formField"><input id="retries" class="w-25 form-control form-control-sm my-2" type="text" value="${dataSource.retries}"/></td>
        </tr>
        <tr>
          <td class="formLabelRequired align-middle my-2 text-uppercase fs-7"><fmt:message key="dsEdit.dnp3.operateMode"/></td>
        </tr>
        <tr>
          <%-- Buscando em -> scadalts-ui/src/components/forms/SleepAndReactivationDS.vue --%>
          <td COLSPAN=2><div id="sleep-reactivation-ds"></td>
        </tr>


<%@ include file="/WEB-INF/jsp/dataSourceEdit/dsEventsFoot.jspf" %>

<tag:pointList pointHelpId="httpRetrieverPP">
  <tr>
    <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.pointDataType"/></td>
    <td class="formField">
      <select class="w-50 form-select form-select-sm my-2" name="dataTypeId" onchange="dataTypeChanged()">
        <tag:dataTypeOptions excludeImage="true"/>
      </select>
    </td>
  </tr>
  
  <tr>
    <td class="formLabelRequired align-middle my-2">
      <fmt:message key="dsEdit.httpRetriever.valueRegex"/>
      <i id="valueTestImg" class="bi bi-gear-fill text-blue-add ms-3 fs-6" title="<fmt:message key='dsEdit.httpRetriever.testValue'/>"  onclick="testValueParams()"></i>
      <%-- <tag:img id="valueTestImg" png="accept" title="dsEdit.httpRetriever.testValue" onclick="testValueParams()"/> --%>
    </td>
    <td class="d-flex align-items-center justify-content-start">
      <input class="w-75 form-control form-control-sm my-2" type="text" id="valueRegex" class="formLong"/>
      <tag:help id="regex"/>
    </td>
  </tr>
  
  <tbody id="valueTestRow" style="display:none">
    <tr>
      <td></td>
      <td id="valueTestResult"></td>
    </tr>
  </tbody>
  
  <tr>
    <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.httpRetriever.ignoreIfMissing"/></td>
    <td class="formField"><input class="form-check-input custom-checkbox my-2" type="checkbox" id="ignoreIfMissing"/></td>
  </tr>
  
  <tbody id="valueFormatRow">
    <tr>
      <td id="valueFormatLabel" class="formLabel"></td>
      <td class="formField">
        <input class="w-75 form-control form-control-sm my-2" type="text" id="valueFormat"/>
        <span id="numberFormatHelp"><tag:help id="numberFormats"/></span>
      </td>
    </tr>
  </tbody>
  
  <tr>
    <td class="formLabel">
      <fmt:message key="dsEdit.httpRetriever.timeRegex"/>
      <i id="timeTestImg" class="bi bi-gear-fill text-blue-add ms-3 fs-6" title="<fmt:message key='dsEdit.httpRetriever.testTime'/>"  onclick="testTimeParams()"></i>
      <%-- <tag:img id="timeTestImg" png="accept" title="dsEdit.httpRetriever.testTime" onclick="testTimeParams()"/> --%>
    </td>
    <td class="d-flex align-items-center justify-content-start">
      <input class="w-75 form-control form-control-sm my-2" type="text" id="timeRegex" onkeyup="timeRegexKU()" class="formLong"/>
      <tag:help id="regex"/>
    </td>
  </tr>
  
  <tbody id="timeTestRow" style="display:none">
    <tr>
      <td></td>
      <td id="timeTestResult"></td>
    </tr>
  </tbody>
  
  <tbody id="timeFormatRow">
    <tr>
      <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.httpRetriever.timeFormat"/></td>
      <td class="formField">
        <input class="w-75 form-control form-control-sm my-2" type="text" id="timeFormat"/>
        <tag:help id="datetimeFormats"/>
      </td>
    </tr>
  </tbody>
</tag:pointList>
<%@ include file="/WEB-INF/jsp/include/vue/vue-app.js.jsp"%>
<%@ include file="/WEB-INF/jsp/include/vue/vue-view.js.jsp"%>

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
<%@page import="com.serotonin.modbus4j.code.RegisterRange"%>
<%@page import="com.serotonin.modbus4j.code.DataType"%>

<script type="text/javascript">

  function initImpl() {
      scanButtons(false);
      changeRange('test_');
  }
  
  function scan() {
      $set("scanMessage", "<fmt:message key="dsEdit.modbus.startScan"/>");
      dwr.util.removeAllOptions("scanNodes");
      scanButtons(true);
      scanImpl();
  }
  
  function scanCB(msg) {
      if (msg)
          alert(msg);
      else
          setTimeout(scanUpdate, 1000);
  }

  function scanUpdate() {
      DataSourceEditDwr.modbusScanUpdate(scanUpdateCB);
  }
  
  function scanUpdateCB(result) {
      if (result) {
          $set("scanMessage", result.message);
          dwr.util.removeAllOptions("scanNodes");
          dwr.util.addOptions("scanNodes", result.nodes);
          if (!result.finished)
              scanCB();
          else
              scanButtons(false);
      }
  }
  
  function scanCancel() {
      DataSourceEditDwr.cancelTestingUtility(scanButtons);
  }
  
  function scanButtons(scanning) {
      setDisabled("scanBtn", scanning);
      setDisabled("scanCancelBtn", !scanning);
  }
  
  function locatorTest() {
      setDisabled("locatorTestBtn", true);
      
      var locator = {};
      locator.slaveId = $get("test_slaveId");
      locator.range = $get("test_range");
      locator.modbusDataType = $get("test_modbusDataType");
      locator.offset = $get("test_offset");
      locator.bit = $get("test_bit");
      locator.registerCount = $get("test_registerCount");
      locator.charset = $get("test_charset");
      
      locatorTestImpl(locator);
  }
  
  function locatorTestCB(response) {
      hideContextualMessages("locatorTestDiv");
      hideGenericMessages("locatorTestGeneric");
      if (response.hasMessages) {
          // Add the prefix to the contextual messages.
          for (var i=0; i<response.messages.length; i++) {
              if (response.messages[i].contextKey)
                  response.messages[i].contextKey = "test_"+ response.messages[i].contextKey;
          }
          showDwrMessages(response.messages, "locatorTestGeneric");
          $set("locatorTestResult");
      }
      else
          $set("locatorTestResult", response.data.result);
      setDisabled("locatorTestBtn", false);
  }
  
  function dataTest() {
      setDisabled("dataTestBtn", true);
      dataTestImpl($get("dataTest_slaveId"), $get("dataTest_range"), $get("dataTest_offset"), $get("dataTest_length"));
      hideGenericMessages("dataTestGeneric");
  }
  
  function dataTestCB(response) {
	  if (response.data.length)
		  $set("dataTest_length", response.data.length);
	  
      if (response.hasMessages) {
          showDwrMessages(response.messages, "dataTestGeneric");
          hide("dataTestResults");
      }
      else {
    	  var results = "";
    	  for (var i=0; i<response.data.results.length; i++)
    		  results += response.data.results[i] +"<br/>";
          $set("dataTestResults", results);
          show("dataTestResults");
      }

      setDisabled("dataTestBtn", false);
  }
  
  function addPointImpl() {
	  DataSourceEditDwr.getPoint(-1, function(point) {
		  editPointCB(point);
	      $set("slaveId", $get("test_slaveId"));
	      $set("range", $get("test_range"));
	      $set("modbusDataType", $get("test_modbusDataType"));
	      $set("offset", $get("test_offset"));
	      $set("bit", $get("test_bit"));
	      $set("registerCount", $get("test_registerCount"));
	      $set("charset", $get("test_charset"));
          changeRange('');
	  });
  }
  
  function appendPointListColumnFunctions(pointListColumnHeaders, pointListColumnFunctions) {
      pointListColumnHeaders[pointListColumnHeaders.length] = "<fmt:message key="dsEdit.modbus.slave"/>";
      pointListColumnFunctions[pointListColumnFunctions.length] = function(p) { return p.pointLocator.slaveId; };
      
      pointListColumnHeaders[pointListColumnHeaders.length] = "<fmt:message key="dsEdit.modbus.range"/>";
      pointListColumnFunctions[pointListColumnFunctions.length] = function(p) {
          if (p.pointLocator.slaveMonitor)
              return "<fmt:message key="dsEdit.modbus.slaveMonitor"/>";
          if (p.pointLocator.socketMonitor)
              return "<fmt:message key="dsEdit.modbus.socketMonitor"/>";
          return p.pointLocator.rangeMessage;
      };
      
      pointListColumnHeaders[pointListColumnHeaders.length] = "<fmt:message key="dsEdit.modbus.offset"/>";
      pointListColumnFunctions[pointListColumnFunctions.length] = function(p) {
    	  if (p.pointLocator.slaveMonitor)
    		  return "";
    	  if (isBinary('', p.pointLocator.modbusDataType) && !isBinaryRange('', p.pointLocator.range))
              return p.pointLocator.offset +'/'+ p.pointLocator.bit;
    	  return p.pointLocator.offset;
  	  };
  }
  
  function editPointCBImpl(locator) {
      $set("slaveId", locator.slaveId);
      $set("range", locator.range);
      $set("modbusDataType", locator.modbusDataType);
      $set("offset", locator.offset);
      $set("bit", locator.bit);
      $set("registerCount", locator.registerCount);
      $set("charset", locator.charset);
      $set("settableOverride", locator.settableOverride);
      $set("multiplier", locator.multiplier);
      $set("additive", locator.additive);

      if (locator.socketMonitor){
          hide("nonSlaveMonitor");
          hide("slaveIdRow", true);
      }
      else if (locator.slaveMonitor) {
          hide("nonSlaveMonitor");
          setDisabled("slaveId", true);
      }
      else {
          setDisabled("slaveId", false);
          show("nonSlaveMonitor");
          changeRange('');
      }
  }
  
  function savePointImpl(locator) {
      delete locator.settable;
      delete locator.rangeMessage;
      delete locator.dataTypeId;
      delete locator.relinquishable;
      
      locator.slaveId = $get("slaveId");
      locator.range = $get("range");
      locator.modbusDataType = $get("modbusDataType");
      locator.offset = $get("offset");
      locator.bit = $get("bit");
      locator.registerCount = $get("registerCount");
      locator.charset = $get("charset");
      locator.settableOverride = $get("settableOverride");
      locator.multiplier = $get("multiplier");
      locator.additive = $get("additive");
      
      DataSourceEditDwr.saveModbusPointLocator(currentPoint.id, $get("xid"), $get("name"), locator, savePointCB);
  }
  
  function changeRange(prefix) {
      if (isBinaryRange(prefix)) {
          $set(prefix +"modbusDataType", "<c:out value="<%= DataType.BINARY %>"/>");
          setDisabled(prefix +"modbusDataType", true);
      }
      else
          setDisabled(prefix +"modbusDataType", false);
      changeDataType(prefix);
      
      var rangeId = $get(prefix +"range");
      if (rangeId == "<c:out value="<%= RegisterRange.COIL_STATUS %>"/>" || rangeId == "<c:out value="<%= RegisterRange.HOLDING_REGISTER %>"/>")
          maybeSetDisabled(prefix +"settableOverride", false);
      else {
    	  maybeSetDisabled(prefix +"settableOverride", true);
          $set(prefix +"settableOverride", false);
      }
  }
  
  function isBinary(prefix, dt) {
	  if (!dt)
		  dt = $get(prefix +"modbusDataType");
      return dt == "<c:out value="<%= DataType.BINARY %>"/>";
  }
  
  function isBinaryRange(prefix, r) {
	  if (!r)
	      r = $get(prefix +"range");
      return r == "<c:out value="<%= RegisterRange.COIL_STATUS %>"/>" || r == "<c:out value="<%= RegisterRange.INPUT_STATUS %>"/>";
  }
  
  function isString(prefix) {
	  var dt = $get(prefix +"modbusDataType");
      return dt == "<c:out value="<%= DataType.CHAR %>"/>" || dt == "<c:out value="<%= DataType.VARCHAR %>"/>";
  }
  
  function changeDataType(prefix) {
	  if (isBinary(prefix)) {
          setDisabled(prefix +"bit", isBinaryRange(prefix));
          setDisabled(prefix +"registerCount", true);
          setDisabled(prefix +"charset", true);
          maybeSetDisabled(prefix +"multiplier", true);
          maybeSetDisabled(prefix +"additive", true);
	  }
	  else if (isString(prefix)) {
          setDisabled(prefix +"bit", true);
          setDisabled(prefix +"registerCount", false);
          setDisabled(prefix +"charset", false);
          maybeSetDisabled(prefix +"multiplier", true);
          maybeSetDisabled(prefix +"additive", true);
	  }
	  else {
          setDisabled(prefix +"bit", true);
          setDisabled(prefix +"registerCount", true);
          setDisabled(prefix +"charset", true);
          maybeSetDisabled(prefix +"multiplier", false);
          maybeSetDisabled(prefix +"additive", false);
	  }
  }
  
  function maybeSetDisabled(nodeName, val) {
	  var node = $(nodeName);
	  if (node)
		  setDisabled(node, val);
  }

  //função para adicionar classes aos selects estilo bootstrap
  function addClassToSelectsIds() {
  var selectGroups = [
    {
    ids: ["range", "test_modbusDataType", "test_range", "dataTest_range", "modbusDataType"],
    classes: ["w-75", "form-select", "form-select-sm", "my-2"]
    },
    {
    ids: ["updatePeriodType", "transportType", "commPortId", "baudRate", "flowControlIn", "flowControlOut", "dataBits", "stopBits", "parity", "encoding", "echo", "concurrency"],
    classes: ["w-25", "form-select", "form-select-sm", "my-2"]
    },
    {
    ids: ["quantize", "contiguousBatches", "createSlaveMonitorPoints", "encapsulated", "createSocketMonitorPoint"],
    classes: ["form-check-input", "custom-checkbox", "my-2"]
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
  window.onload = addClassToSelectsIds;
</script>

<c:choose>
  <c:when test="${dataSource.type.id == applicationScope['constants.DataSourceVO.Types.MODBUS_SERIAL']}">
    <c:set var="dsDesc"><fmt:message key="dsEdit.modbus.descSerial"/></c:set>
    <c:set var="dsHelpId" value="modbusSerialDS"/>
  </c:when>
  <c:when test="${dataSource.type.id == applicationScope['constants.DataSourceVO.Types.MODBUS_IP']}">
    <c:set var="dsDesc"><fmt:message key="dsEdit.modbus.descIp"/></c:set>
    <c:set var="dsHelpId" value="modbusIpDS"/>
  </c:when>
</c:choose>
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
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.quantize"/></td>
          <td class="formField"><sst:checkbox id="quantize" selectedValue="${dataSource.quantize}"/></td>
        </tr>
              
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.timeout"/></td>
          <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="timeout" value="${dataSource.timeout}"/></td>
        </tr>
              
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.retries"/></td>
          <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="retries" value="${dataSource.retries}"/></td>
        </tr>
              
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.contiguousBatches"/></td>
          <td class="formField"><sst:checkbox id="contiguousBatches" selectedValue="${dataSource.contiguousBatches}"/></td>
        </tr>
              
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.createSlaveMonitorPoints"/></td>
          <td class="formField"><sst:checkbox id="createSlaveMonitorPoints" selectedValue="${dataSource.createSlaveMonitorPoints}"/></td>
        </tr>
              
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.maxReadBitCount"/></td>
          <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="maxReadBitCount" value="${dataSource.maxReadBitCount}"/></td>
        </tr>
              
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.maxReadRegisterCount"/></td>
          <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="maxReadRegisterCount" value="${dataSource.maxReadRegisterCount}"/></td>
        </tr>
              
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.maxWriteRegisterCount"/></td>
          <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="maxWriteRegisterCount" value="${dataSource.maxWriteRegisterCount}"/></td>
        </tr>
              
        <c:choose>
          <c:when test="${dataSource.type.id == applicationScope['constants.DataSourceVO.Types.MODBUS_SERIAL']}">
            <%@ include file="/WEB-INF/jsp/dataSourceEdit/editModbusSerial.jsp" %>
          </c:when>
          <c:when test="${dataSource.type.id == applicationScope['constants.DataSourceVO.Types.MODBUS_IP']}">
            <%@ include file="/WEB-INF/jsp/dataSourceEdit/editModbusIp.jsp" %>
          </c:when>
        </c:choose>
      </table>
      <tag:dsEvents/>
    </div>
  </td>
  
  <td valign="top">
    <div class="right-box w-50 m-3" style="float:left;">
      <table class="m-3">
        <tr><td colspan="2" class="smallTitle"><fmt:message key="dsEdit.modbus.nodeScan"/></td></tr>
        <tr>
          <td colspan="2" align="center">
            <button id="scanBtn" class="btn btn-primary custom-btn-blue ms-3" onclick="scan();" ><fmt:message key="dsEdit.modbus.scanForNodes"/></button>
            <%-- <input id="scanBtn" type="button" value="<fmt:message key="dsEdit.modbus.scanForNodes"/>" onclick="scan();"/> --%>
            <button id="scanCancelBtn" class="btn btn-primary custom-btn-blue ms-3" onclick="scanCancel();" ><fmt:message key="common.cancel"/></button>
            <%-- <input id="scanCancelBtn" type="button" value="<fmt:message key="common.cancel"/>" onclick="scanCancel();"/> --%>
          </td>
        </tr>
        
        <tr><td colspan="2" id="scanMessage" class="formError"></td></tr>
        
        <tr class="d-flex align-items-center justify-content-start w-100">
          <td class="formLabelRequired align-middle my-2 text-uppercase"><fmt:message key="dsEdit.modbus.nodesFound"/></td>
          <td class="formField"><select id="scanNodes" class="form-select w-75" size="10"></select></td>
        </tr>
      </table>
    </div>
    
    <div class="right-box w-50 m-3" style="float:left;">
      <table class="m-3">
        <tr><td colspan="2" class="smallTitle"><fmt:message key="dsEdit.modbus.dataTest"/></td></tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.slaveId"/></td>
          <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="dataTest_slaveId" value="1"/></td>
        </tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.registerRange"/></td>
          <td class="formField">
            <select id="dataTest_range">
              <option value="<c:out value="<%= RegisterRange.COIL_STATUS %>"/>"><fmt:message key="dsEdit.modbus.coilStatus"/></option>
              <option value="<c:out value="<%= RegisterRange.INPUT_STATUS %>"/>"><fmt:message key="dsEdit.modbus.inputStatus"/></option>
              <option value="<c:out value="<%= RegisterRange.HOLDING_REGISTER %>"/>"><fmt:message key="dsEdit.modbus.holdingRegister"/></option>
              <option value="<c:out value="<%= RegisterRange.INPUT_REGISTER %>"/>"><fmt:message key="dsEdit.modbus.inputRegister"/></option>
            </select>
          </td>
        </tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.offset"/></td>
          <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="dataTest_offset" value="0"/></td>
        </tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.registerCount"/></td>
          <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="dataTest_length" value="100"/></td>
        </tr>
        
        <tr>
          <td colspan="2" align="center">
            <button id="dataTestBtn" class="btn btn-primary custom-btn-blue ms-3" onclick="dataTest();" ><fmt:message key="dsEdit.modbus.dataTest.read"/></button>
            <%-- <input id="dataTestBtn" type="button" value="<fmt:message key="dsEdit.modbus.dataTest.read"/>" onclick="dataTest();"/> --%>
          </td>
        </tr>
        
        <tr><td colspan="2"><div id="dataTestResults" style="height: 200px; width: 100%; overflow: scroll; display: none;"></div></td></tr>
        
        <tr><td colspan="2"><table><tbody id="dataTestGeneric"></tbody></table></td></tr> 
      </table>
    </div>
    
    <div class="right-box w-50 m-3" id="locatorTestDiv" style="clear:both;">
      <table class="m-3">
        <tr><td colspan="2" class="smallTitle"><fmt:message key="dsEdit.modbus.locatorTest"/></td></tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.slaveId"/></td>
          <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="test_slaveId" value="1"/></td>
        </tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.registerRange"/></td>
          <td class="formField">
            <select id="test_range" onchange="changeRange('test_')">
              <option value="<c:out value="<%= RegisterRange.COIL_STATUS %>"/>"><fmt:message key="dsEdit.modbus.coilStatus"/></option>
              <option value="<c:out value="<%= RegisterRange.INPUT_STATUS %>"/>"><fmt:message key="dsEdit.modbus.inputStatus"/></option>
              <option value="<c:out value="<%= RegisterRange.HOLDING_REGISTER %>"/>"><fmt:message key="dsEdit.modbus.holdingRegister"/></option>
              <option value="<c:out value="<%= RegisterRange.INPUT_REGISTER %>"/>"><fmt:message key="dsEdit.modbus.inputRegister"/></option>
            </select>
          </td>
        </tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.modbusDataType"/></td>
          <td class="formField">
            <select id="test_modbusDataType" onchange="changeDataType('test_')">
              <option value="<c:out value="<%= DataType.BINARY %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.binary"/></option>
              <option value="<c:out value="<%= DataType.TWO_BYTE_INT_UNSIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.2bUnsigned"/></option>
              <option value="<c:out value="<%= DataType.TWO_BYTE_INT_SIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.2bSigned"/></option>
              <option value="<c:out value="<%= DataType.TWO_BYTE_BCD %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.2bBcd"/></option>
              <option value="<c:out value="<%= DataType.FOUR_BYTE_INT_UNSIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bUnsigned"/></option>
              <option value="<c:out value="<%= DataType.FOUR_BYTE_INT_SIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bSigned"/></option>
              <option value="<c:out value="<%= DataType.FOUR_BYTE_INT_UNSIGNED_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bUnsignedSwapped"/></option>
              <option value="<c:out value="<%= DataType.FOUR_BYTE_INT_SIGNED_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bSignedSwapped"/></option>
              <option value="<c:out value="<%= DataType.FOUR_BYTE_FLOAT %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bFloat"/></option>
              <option value="<c:out value="<%= DataType.FOUR_BYTE_FLOAT_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bFloatSwapped"/></option>
              <option value="<c:out value="<%= DataType.FOUR_BYTE_FLOAT_SWAPPED_INVERTED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bFloatSwappedInverted"/></option>            
              <option value="<c:out value="<%= DataType.FOUR_BYTE_BCD %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bBcd"/></option>
              <option value="<c:out value="<%= DataType.EIGHT_BYTE_INT_UNSIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bUnsigned"/></option>
              <option value="<c:out value="<%= DataType.EIGHT_BYTE_INT_SIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bSigned"/></option>
              <option value="<c:out value="<%= DataType.EIGHT_BYTE_INT_UNSIGNED_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bUnsignedSwapped"/></option>
              <option value="<c:out value="<%= DataType.EIGHT_BYTE_INT_SIGNED_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bSignedSwapped"/></option>
              <option value="<c:out value="<%= DataType.EIGHT_BYTE_FLOAT %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bFloat"/></option>
              <option value="<c:out value="<%= DataType.EIGHT_BYTE_FLOAT_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bFloatSwapped"/></option>
              <option value="<c:out value="<%= DataType.CHAR %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.char"/></option>
              <option value="<c:out value="<%= DataType.VARCHAR %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.varchar"/></option>
            </select>
          </td>
        </tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.offset"/></td>
          <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="test_offset" value="0"/></td>
        </tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.bit"/></td>
          <td class="formField"><input id="test_bit" class="w-75 form-control form-control-sm my-2" type="text" value="0"/></td>
        </tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.registerCount"/></td>
          <td class="formField"><input id="test_registerCount" class="w-75 form-control form-control-sm my-2" type="text" value="0"/></td>
        </tr>
        
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.charset"/></td>
          <td class="formField"><input id="test_charset" class="w-75 form-control form-control-sm my-2" type="text" value="ASCII"/></td>
        </tr>
        
        <tr>
          <td colspan="2" align="center">
            <button id="locatorTestBtn" class="btn btn-primary custom-btn-blue ms-3" onclick="locatorTest();" ><fmt:message key="dsEdit.modbus.locatorTest.test"/></button>
            <%-- <input id="locatorTestBtn" type="button" value="<fmt:message key="dsEdit.modbus.locatorTest.test"/>" onclick="locatorTest();"/> --%>
            <button class="btn btn-primary custom-btn-blue ms-3" onclick="addPoint();" ><fmt:message key="dsEdit.modbus.addPoint"/></button>
            <%-- <input type="button" value="<fmt:message key="dsEdit.modbus.addPoint"/>" onclick="addPoint();"/> --%>
          </td>
        </tr>
        
        <tr><td colspan="2" id="locatorTestResult" class="formError"></td></tr>
        <tr><td colspan="2"><table><tbody id="locatorTestGeneric"></tbody></table></td></tr> 
        
<%@ include file="/WEB-INF/jsp/dataSourceEdit/dsFoot.jspf" %>

<tag:pointList pointHelpId="modbusPP">
  <tr id="slaveIdRow">
    <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.slaveId"/></td>
    <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="slaveId"/></td>
  </tr>
  
  <tbody id="nonSlaveMonitor">
    <tr>
      <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.registerRange"/></td>
      <td class="formField">
        <select id="range" onchange="changeRange('')">
          <option value="<c:out value="<%= RegisterRange.COIL_STATUS %>"/>"><fmt:message key="dsEdit.modbus.coilStatus"/></option>
          <option value="<c:out value="<%= RegisterRange.INPUT_STATUS %>"/>"><fmt:message key="dsEdit.modbus.inputStatus"/></option>
          <option value="<c:out value="<%= RegisterRange.HOLDING_REGISTER %>"/>"><fmt:message key="dsEdit.modbus.holdingRegister"/></option>
          <option value="<c:out value="<%= RegisterRange.INPUT_REGISTER %>"/>"><fmt:message key="dsEdit.modbus.inputRegister"/></option>
        </select>
      </td>
    </tr>
    
    <tr>
      <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.modbusDataType"/></td>
      <td class="formField">
        <select id="modbusDataType" onchange="changeDataType('')">
          <option value="<c:out value="<%= DataType.BINARY %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.binary"/></option>
          <option value="<c:out value="<%= DataType.TWO_BYTE_INT_UNSIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.2bUnsigned"/></option>
          <option value="<c:out value="<%= DataType.TWO_BYTE_INT_SIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.2bSigned"/></option>
          <option value="<c:out value="<%= DataType.TWO_BYTE_BCD %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.2bBcd"/></option>
          <option value="<c:out value="<%= DataType.FOUR_BYTE_INT_UNSIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bUnsigned"/></option>
          <option value="<c:out value="<%= DataType.FOUR_BYTE_INT_SIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bSigned"/></option>
          <option value="<c:out value="<%= DataType.FOUR_BYTE_INT_UNSIGNED_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bUnsignedSwapped"/></option>
          <option value="<c:out value="<%= DataType.FOUR_BYTE_INT_SIGNED_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bSignedSwapped"/></option>
          <option value="<c:out value="<%= DataType.FOUR_BYTE_FLOAT %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bFloat"/></option>
          <option value="<c:out value="<%= DataType.FOUR_BYTE_FLOAT_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bFloatSwapped"/></option>
          <option value="<c:out value="<%= DataType.FOUR_BYTE_FLOAT_SWAPPED_INVERTED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bFloatSwappedInverted"/></option>            
          <option value="<c:out value="<%= DataType.FOUR_BYTE_BCD %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.4bBcd"/></option>
          <option value="<c:out value="<%= DataType.EIGHT_BYTE_INT_UNSIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bUnsigned"/></option>
          <option value="<c:out value="<%= DataType.EIGHT_BYTE_INT_SIGNED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bSigned"/></option>
          <option value="<c:out value="<%= DataType.EIGHT_BYTE_INT_UNSIGNED_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bUnsignedSwapped"/></option>
          <option value="<c:out value="<%= DataType.EIGHT_BYTE_INT_SIGNED_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bSignedSwapped"/></option>
          <option value="<c:out value="<%= DataType.EIGHT_BYTE_FLOAT %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bFloat"/></option>
          <option value="<c:out value="<%= DataType.EIGHT_BYTE_FLOAT_SWAPPED %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.8bFloatSwapped"/></option>
          <option value="<c:out value="<%= DataType.CHAR %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.char"/></option>
          <option value="<c:out value="<%= DataType.VARCHAR %>"/>"><fmt:message key="dsEdit.modbus.modbusDataType.varchar"/></option>
        </select>
      </td>
    </tr>
    
    <tr>
      <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.offset"/></td>
      <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="offset"/></td>
    </tr>
    
    <tr>
      <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.bit"/></td>
      <td class="formField"><input id="bit" class="w-75 form-control form-control-sm my-2" type="text"/></td>
    </tr>
    
    <tr>
      <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.registerCount"/></td>
      <td class="formField"><input id="registerCount" class="w-75 form-control form-control-sm my-2" type="text"/></td>
    </tr>
    
    <tr>
      <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.charset"/></td>
      <td class="formField"><input id="charset" class="w-75 form-control form-control-sm my-2" type="text"/></td>
    </tr>
    
    <tr>
      <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.modbus.settableOverride"/></td>
      <td class="formField"><input id="settableOverride" class="form-check-input custom-checkbox my-2" type="checkbox"/></td>
    </tr>
    
    <tr>
      <td class="formLabel"><fmt:message key="dsEdit.modbus.multiplier"/></td>
      <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="multiplier"/></td>
    </tr>
    
    <tr>
      <td class="formLabel"><fmt:message key="dsEdit.modbus.additive"/></td>
      <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="additive"/></td>
    </tr>
  </tbody>
</tag:pointList>
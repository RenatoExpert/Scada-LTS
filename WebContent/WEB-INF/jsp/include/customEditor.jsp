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
<div id="customEditorPopup" style="display:none;left:0px;top:0px;" class="windowDiv">
  <table cellpadding="0" cellspacing="0"  class="m-3"><tr><td>
    <table width="100%">
      <tr>
        <td>
          <i class="bi bi-bar-chart text-success align-middle mx-3 fs-6" title="<fmt:message key='viewEdit.graphic.editor'/>" style="display:inline;"></i>
          <span class="copyTitle" id="graphicsComponentName"></span>
							<span style="font-size: 16px;">
							<sst:i18n key='viewEdit.graphic.editor' escapeDQuotes='true'/>
							</span>
        </td>
        <td align="right">
            <i class="bi bi-floppy2-fill text-success align-middle ms-3 fs-6" onclick="customEditor.save()" title="<fmt:message key='common.save'/>" style="display:inline;"></i>&nbsp;
            <i class="bi bi-x-lg text-danger align-middle ms-3 fs-6" onclick="customEditor.close()" title="<fmt:message key='common.close'/>" style="display:inline;"></i>
        </td>
      </tr>
    </table>
    
    <table>
      <tbody id="customEditor_alarmlist" style="display:none;">
      	<tr>
          <td class="formLabel  align-middle my-2"><fmt:message key="common.alarmLevel"/></td>
          <td class="formField"><select  class="w-50 form-select form-select-sm my-2" id="customEditorAlarmListMinAlarmLevel"><tag:alarmLevelOptions allOption="true"/></select></td>
        </tr>
      	<tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="viewEdit.graphic.maxListSize"/></td>
          <td class="formField"><input id="customEditorAlarmListMaxListSize" class="w-75 form-control form-control-sm my-2" type="text"/></td>
        </tr>
        <tr>
          <td class="formLabelRequired align-middle my-2"><fmt:message key="viewEdit.graphic.width"/></td>
          <td class="formField"><input id="customEditorAlarmListWidth" class="w-75 form-control form-control-sm my-2" type="text"/></td>
        </tr>
        <tr>
          <td class="formLabel  align-middle my-2"><fmt:message key="viewEdit.graphic.hideIdColumn"/></td>
          <td class="formField"><input id="customEditorAlarmListIdColumn" class="form-check-input custom-checkbox my-2" type="checkbox"/></td>
        </tr>
        <tr>
          <td class="formLabel  align-middle my-2"><fmt:message key="viewEdit.graphic.hideAlarmLevelColumn"/></td>
          <td class="formField"><input id="customEditorAlarmListAlarmLevelColumn" class="form-check-input custom-checkbox my-2" type="checkbox"/></td>
        </tr>
        <tr>
          <td class="formLabel  align-middle my-2"><fmt:message key="viewEdit.graphic.hideTimestampColumn"/></td>
          <td class="formField"><input id="customEditorAlarmListTimestampColumn" class="form-check-input custom-checkbox my-2" type="checkbox"/></td>
        </tr>
        <tr>
          <td class="formLabel  align-middle my-2"><fmt:message key="viewEdit.graphic.hideInactivityColumn"/></td>
          <td class="formField"><input id="customEditorAlarmListInactivityColumn" class="form-check-input custom-checkbox my-2" type="checkbox"/></td>
        </tr>
        <tr>
          <td class="formLabel  align-middle my-2"><fmt:message key="viewEdit.graphic.hideAckColumn"/></td>
          <td class="formField"><input id="customEditorAlarmListAckColumn" class="form-check-input custom-checkbox my-2" type="checkbox"/></td>
        </tr>
      </tbody>
      
      <tbody id="customEditor_button" style="display:none;">
        
      </tbody>
      
    </table>
  </td></tr></table>
  
  <script type="text/javascript">
    var viewId = mango.longPoll.pollRequest.viewId;
    function CustomEditor() {
        this.componentId = null;
        this.typeName = null;
        
        this.open = function(compId) {
            customEditor.componentId = compId;
            
            // Set the renderers for the data type of this point view.
            ViewDwr.getViewComponent(compId, viewId, customEditor.setViewComponent);
            
        };

        this.setViewComponent = function(comp) {
            customEditor.typeName = comp.typeName;

            // Update the data in the form.
            if (comp.typeName == "alarmlist") {
            	$set("customEditorAlarmListMinAlarmLevel",comp.minAlarmLevel);
                $set("customEditorAlarmListMaxListSize",comp.maxListSize);
                $set("customEditorAlarmListWidth",comp.width);
                $set("customEditorAlarmListIdColumn",comp.hideIdColumn);
                $set("customEditorAlarmListAlarmLevelColumn",comp.hideAlarmLevelColumn);
                $set("customEditorAlarmListTimestampColumn",comp.hideTimestampColumn);
                $set("customEditorAlarmListInactivityColumn",comp.hideInactivityColumn);
                $set("customEditorAlarmListAckColumn",comp.hideAckColumn);

            } else if(comp.typeName == "yourCustomComponent") {

            }
            show("customEditor_"+ comp.typeName);
            positionCustomEditor(comp.id, "customEditorPopup");
            show("customEditorPopup");
        };
    
        this.close = function() {
            hide("customEditorPopup");
            //hideContextualMessages("customEditorPopup");
            if (customEditor.typeName)
                hide("customEditor_"+ customEditor.typeName);
        };
        
        this.save = function() {
            //hideContextualMessages("graphicRendererEditorPopup");
            if (customEditor.typeName == "alarmlist")
            	ViewDwr.saveAlarmListComponent(customEditor.componentId,
                    	$get("customEditorAlarmListMinAlarmLevel"), $get("customEditorAlarmListMaxListSize"),
                        $get("customEditorAlarmListWidth"),$get("customEditorAlarmListIdColumn"),
                        $get("customEditorAlarmListAlarmLevelColumn"),$get("customEditorAlarmListTimestampColumn"),
                        $get("customEditorAlarmListInactivityColumn"),$get("customEditorAlarmListAckColumn"),
                        viewId, customEditor.saveCB);
            else if (customEditor.typeName == "yourCustomComponent")
            	alert('save your custom component component!');
            
        };
        
        this.saveCB = function(response) {
            if (response.hasMessages)
                showDwrMessages(response.messages);
            else {
                customEditor.close();
                MiscDwr.notifyLongPoll(mango.longPoll.pollSessionId);
            }
        };
        
    }
    var customEditor = new CustomEditor();
  </script>
</div>
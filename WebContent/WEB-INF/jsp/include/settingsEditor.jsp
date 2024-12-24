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
<link href="resources/jQuery/plugins/chosen/chosen.min.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" src="resources/jQuery/plugins/chosen/chosen.jquery.min.js"></script>
<%@ include file="/WEB-INF/jsp/include/tech.jsp" %>
<div id="settingsEditorPopup" style="display:none;left:0px;top:0px;" class="windowDiv">
  <div>
  <table cellpadding="0" cellspacing="0" class="m-3"><tr><td>
    <table width="100%" class="m-3">
      <tr>
        <td>
          <i class="bi bi-pencil-fill text-success align-middle mx-3 fs-6" title="<fmt:message key='viewEdit.settings.editor'/>" style="display:inline;"></i>
							<span style="font-size: 16px;">
							<sst:i18n key='viewEdit.settings.editor' escapeDQuotes='true'/> - </span>
          <span class="copyTitle" id="settingsComponentName"></span>
        </td>
        <td align="right">
          <i class="bi bi-floppy2-fill text-success align-middle mx-3 fs-6" onclick="settingsEditor.save()" title="<fmt:message key='common.save'/>" style="display:inline;"></i>&nbsp;
          <i class="bi bi-x-lg text-danger align-middle mx-3 fs-6" onclick="settingsEditor.close()" title="<fmt:message key='common.close'/>" style="display:inline;"></i>
        </td>
      </tr>
    </table>
    <table>
      <tr>
        <td class="formLabelRequired align-middle my-2"><fmt:message key="viewEdit.settings.point"/></td>
        <td class="formField"><select class="w-50 form-select form-select-sm my-2" id="settingsPointList" onchange="settingsEditor.pointSelectChanged()"></select></td>
      </tr>
      <tr>
        <td class="formLabel align-middle my-2"><fmt:message key="viewEdit.settings.nameOverride"/></td>
        <td class="formField"><input id="settingsPointName" class="w-75 form-control form-control-sm my-2" type="text"/></td>
      </tr>
      <tr>
        <td class="formLabel align-middle my-2"><fmt:message key="viewEdit.settings.settableOverride"/></td>
        <td class="formField"><input id="settingsSettable" class="form-check-input custom-checkbox my-2" type="checkbox"/></td>
      </tr>
      <tr>
        <td class="formLabel align-middle my-2"><fmt:message key="viewEdit.settings.background"/></td>
        <td class="formField"><input id="settingsBkgdColor" class="w-75 form-control form-control-sm my-2" type="text"/></td>
      </tr>
      <tr>
        <td class="formLabel align-middle my-2"><fmt:message key="viewEdit.settings.displayControls"/></td>
        <td class="formField"><input id="settingsControls" class="form-check-input custom-checkbox my-2" type="checkbox"/></td>
      </tr>
      <tr>
        <td class="formLabel align-middle my-2"><fmt:message key="viewEdit.position.x"/></td>
        <td class="formField"><input id="settingsPositionX" class="w-25 form-control form-control-sm my-2" type="number"/></td></td>
      </tr>
      <tr>
        <td class="formLabel align-middle my-2"><fmt:message key="viewEdit.position.y"/></td>
        <td class="formField"><input id="settingsPositionY" class="w-25 form-control form-control-sm my-2" type="number"/></td></td>
      </tr>
    </table>
  </td></tr></table>
  
  <script type="text/javascript">
    var viewId = mango.longPoll.pollRequest.viewId;
    // Script requires
    //  - Drag and Drop library for locating objects and positioning the window.
    //  - DWR utils for using $() prototype.
    //  - common.js
    function SettingsEditor() {
        this.componentId = null;
        this.pointList = [];
        
        this.open = function(compId) {
            document.getElementById("settingsEditorPopup").firstElementChild.setAttribute("id", "settings" + compId);
            settingsEditor.componentId = compId;
            
            ViewDwr.getViewComponent(compId, viewId, function(comp) {
            	
                $set("settingsComponentName", comp.displayName);
                
                // Update the point list
                settingsEditor.updatePointList(comp.supportedDataTypes);
                
                // Update the data in the form.
                $set("settingsPointList", comp.dataPointId);
                $set("settingsPointName", comp.nameOverride);
                $set("settingsSettable", comp.settableOverride);
                $set("settingsBkgdColor", comp.bkgdColorOverride);
                $set("settingsControls", comp.displayControls);                
                $set("settingsPositionX", comp.x);
                $set("settingsPositionY", comp.y);
                
                settingsEditor.pointSelectChanged();
                
                jQuery("#settingsPointList").chosen({
            		placeholder_text_single: " ",
            		search_contains: true,
            		width: "600px"
            	});
                
                jQuery("#settingsPointList").trigger('chosen:updated');

                positionEditor(compId, "settingsEditorPopup");
                show("settingsEditorPopup");
            });
        };
        
        this.close = function() {
            hide("settingsEditorPopup");
            hideContextualMessages("settingsEditorPopup");
        };
        
        this.save = function() {
            hideContextualMessages("settingsEditorPopup");
            let posX = $get("settingsPositionX");
            let posY = $get("settingsPositionY");
            [posX, posY] = validateComponentPosition(posX, posY);
            updatePointPosition(settingsEditor.componentId,
              posX, posY, "settingsPositionX", "settingsPositionY"
            );
            ViewDwr.setPointComponentSettings(settingsEditor.componentId, $get("settingsPointList"),
                    $get("settingsPointName"), $get("settingsSettable"), $get("settingsBkgdColor"),
                    $get("settingsControls"), posX, posY, viewId, function(response) {
                if (response.hasMessages) {
                    showDwrMessages(response.messages);
                }
                else {
                    settingsEditor.close();
                    MiscDwr.notifyLongPoll(mango.longPoll.pollSessionId);
                }
            });
        };
        
        this.setPointList = function(pointList) {
            settingsEditor.pointList = pointList;
        };
        
        this.pointSelectChanged = function() {
            var point = getElement(settingsEditor.pointList, $get("settingsPointList"));
            if (!point || !point.settable) {
                $set("settingsSettable", false);
                $("settingsSettable").disabled = true;
            }
            else
                $("settingsSettable").disabled = false;
        };
        
        this.updatePointList = function(dataTypes) {
            dwr.util.removeAllOptions("settingsPointList");
            		
            for (i=0; i<settingsEditor.pointList.length; i++) {
				if (contains(dataTypes, settingsEditor.pointList[i].dataType)) {
				jQuery("#settingsPointList").append( new Option(
							settingsEditor.pointList[i].name,
							settingsEditor.pointList[i].id) );
				}
			}
            jQuery("#settingsPointList").append( new Option('',-1) );
        };
    }
    var settingsEditor = new SettingsEditor();
  </script>
  </div>
</div>
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
<%@ include file="/WEB-INF/jsp/include/tech.jsp"%>

<tag:page dwr="EmportDwr" onload="init">
	<script type="text/javascript">
    function init() {
        setDisabled("cancelBtn", true);
        importUpdate();
        dataPointsCheckboxChanged();
        $set("includePointValues",true);
        $set("includeUploadsFolder",true);
    }
    
    function doExportJson() {
        setDisabled("exportJsonBtn", true);
        EmportDwr.createExportData($get("prettyIndent"), $get("graphicalViews"), $get("eventHandlers"),
                $get("dataSources"), $get("dataPoints"), $get("scheduledEvents"), $get("compoundEventDetectors"),
                $get("pointLinks"), $get("users"), $get("pointHierarchy"), $get("mailingLists"), $get("publishers"),
                $get("watchLists"), $get("maintenanceEvents"),$get("scripts"),$get("pointValues"),$get("pointValuesMax"),
                $get("systemSettings"), $get("usersProfiles"), $get("reports"), function(data) {
            $set("emportData", data);
            setDisabled("exportJsonBtn", false);
        });
    }

    function doExport() {
      projectName = $get("projectName");

      if(projectName == null || projectName.trim().length == 0) {
    	  messages = [createValidationMessage("projectName","<fmt:message key="emport.invalidProjectName"/>")];
  		  showDwrMessages(messages);
    	  return;
      }

      projectDescription = $get("projectDescription");
      includePointValues = $get("includePointValues");
      pointValuesMaxZip = $get("pointValuesMaxZip");
      includeUploadsFolder = $get("includeUploadsFolder");
      includeGraphicsFolder = $get("includeGraphicsFolder");

	  parameters =   "?projectName="+projectName
	  				+"&includePointValues="+includePointValues
	  				+"&includeUploadsFolder="+includeUploadsFolder
	  				+"&includeGraphicsFolder="+includeGraphicsFolder
	  				+"&projectDescription="+projectDescription
	  				+"&pointValuesMaxZip="+pointValuesMaxZip;

      w = window.open("export_project.htm"+parameters, "_blank");
    }

    function doImport() {
        setDisabled("importJsonBtn", true);
        hideGenericMessages("importMessages");
        $set("alternateMessage", "<fmt:message key="emport.importProgress"/>");
        EmportDwr.importData($get("emportData"), function(response) {
            if (response.data.importStarted)
                importUpdate();
            else if (response.hasMessages) {
                showDwrMessages(response.messages, $("importMessages"));
                $set("alternateMessage");
                setDisabled("importJsonBtn", false);
            }
            else {
                $set("alternateMessage", "<fmt:message key="emport.noMessages"/>");
                setDisabled("importJsonBtn", false);
            }
        });
    }
    
    function importUpdate() {
        EmportDwr.importUpdate(function(response) {
            if (response.data.noImport)
                // no op
                return;
            
            $set("alternateMessage", "<fmt:message key="emport.importProgress"/>");
            setDisabled("importJsonBtn", true);
            setDisabled("cancelBtn", false);
            
            showDwrMessages(response.messages, $("importMessages"));
            
            if (response.data.cancelled || response.data.complete) {
                setDisabled("importJsonBtn", false);
                setDisabled("cancelBtn", true);
                
                if (response.data.cancelled)
                    $set("alternateMessage", "<fmt:message key="emport.importCancelled"/>");
                else
                    $set("alternateMessage", "<fmt:message key="emport.importComplete"/>");
            }
            else
                setTimeout(importUpdate, 1000);
        });
    }

    function changingProject() {
        EmportDwr.importUpdate(function(response) {
            if (response.data.noImport)
                // no op
                return;
            
            $set("alternateMessage", "<fmt:message key="emport.importProgress"/>");
            setDisabled("importJsonBtn", true);
            setDisabled("cancelBtn", false);
            
            showDwrMessages(response.messages, $("changingProjectMessages"));
            
            if (response.data.cancelled || response.data.complete) {
                setDisabled("importJsonBtn", false);
                setDisabled("cancelBtn", true);
                
                if (response.data.cancelled)
                    $set("alternateMessage", "<fmt:message key="emport.importCancelled"/>");
                else
                    $set("alternateMessage", "<fmt:message key="emport.importComplete"/>");
            }
            else
                setTimeout(changingProject, 1000);
        });
    }
    
    function importCancel() {
        EmportDwr.importCancel();
    }
    
    function selectAll(checked) {
        $set("graphicalViews", checked);
        $set("eventHandlers", checked);
        $set("dataSources", checked);
        $set("dataPoints", checked);
        $set("pointValues", checked);
        $set("scheduledEvents", checked);
        $set("compoundEventDetectors", checked);
        $set("pointLinks", checked);
        $set("users", checked);
        $set("pointHierarchy", checked);
        $set("mailingLists", checked);
        $set("publishers", checked);
        $set("watchLists", checked);
        $set("maintenanceEvents", checked);
        $set("scripts", checked);
        dataPointsCheckboxChanged();
        $set("pointValues", checked);
        $set("systemSettings", checked);
        $set("usersProfiles", checked);
        $set("reports", checked);
    }

    function dataPointsCheckboxChanged() {
		if($get("dataPoints")) {
			$("pointValues").disabled = false;
		} else {
			$("pointValues").disabled = true;
			$set("pointValues", false);
		}
    }


    function checkFileToImport() {
    	var ext = $get("importFile");
    	ext = ext.substring(ext.length-3,ext.length);
    	ext = ext.toLowerCase();
    	
    	if(ext != 'zip') {
			messages = [createValidationMessage("importFile","Arquivo de importa��o inv�lido! Arquivo deve ter extens�o .zip!")];
    		showDwrMessages(messages);
        	return false;	
    	}

    	changingProject();
    	return true;
    }

  </script>

<div class="container">
	<div class="row">
		<div class="col-md-6">
			<div class="right-box my-3">
				<table class="w-100 m-3">
					<tr>
						<td colspan="2"><span class="smallTitle"><fmt:message key="emport.export" /></span> <tag:help id="emport" /></td>
					</tr>
						<tr>
							<td><hr class="border border-secondary w-100 ms-4 my-2 mx-auto"/></td>
							<td><hr class="border border-secondary w-75 my-4 me-5 mx-auto"/></td>
						</tr>
					<tr>
						<td class="formLabel"><b><fmt:message key="emport.select" /></b><br />
						</td>
						<td> 
							<a href="#" onclick="selectAll(true); return false"><fmt:message key="emport.selectAll" /></a> | 
							<a href="#" onclick="selectAll(false); return false"><fmt:message key="emport.unselectAll" /></a>
						</td><br/>
					</tr>
					<tr>
						<td class="formField" style="padding-left: 50px;">
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="watchLists" /> 
							<label class="align-middle m-2" for="watchLists"><fmt:message key="header.watchLists" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="graphicalViews" /> 
							<label class="align-middle m-2" for="graphicalViews"><fmt:message key="header.views" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="eventHandlers" /> 
							<label class="align-middle m-2" for="eventHandlers"><fmt:message key="header.eventHandlers" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="dataSources" /> 
							<label class="align-middle m-2" for="dataSources"><fmt:message key="header.dataSources" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="dataPoints" onchange="dataPointsCheckboxChanged();" /> 
							<label class="align-middle m-2" for="dataPoints"><fmt:message key="emport.dataPoints" /></label><br />
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="pointValues" /> 
							<label class="text-danger align-middle m-2" for="pointValues"><fmt:message key="emport.pointValues" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="scheduledEvents" /> 
							<label class="align-middle m-2" for="scheduledEvents"><fmt:message key="header.scheduledEvents" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="compoundEventDetectors" /> 
							<label class="align-middle m-2" for="compoundEventDetectors"><fmt:message key="header.compoundEvents" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="pointLinks" /> 
							<label class="align-middle m-2" for="pointLinks"><fmt:message key="header.pointLinks" /></label><br />
						</td>
						<td>
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="users" /> 
							<label class="align-middle m-2" for="users"><fmt:message key="header.users" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="pointHierarchy" /> 
							<label class="align-middle m-2" for="pointHierarchy"><fmt:message key="header.pointHierarchy" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="mailingLists" /> 
							<label class="align-middle m-2" for="mailingLists"><fmt:message key="header.mailingLists" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="publishers" /> 
							<label class="align-middle m-2" for="publishers"><fmt:message key="header.publishers" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="maintenanceEvents" /> 
							<label class="align-middle m-2" for="maintenanceEvents"><fmt:message key="header.maintenanceEvents" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="scripts" /> 
							<label class="align-middle m-2" for="scripts"><fmt:message key="header.scripts" /></label><br /> 
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="systemSettings" /> 
							<label class="align-middle m-2" for="systemSettings"><fmt:message key="header.systemSettings" /></label><br />
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="usersProfiles" /> 
							<label class="align-middle m-2" for="usersProfiles"><fmt:message key="header.usersProfiles" /></label><br />
							<input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="reports" /> 
							<label class="align-middle m-2" for="reports"><fmt:message key="header.reports" /></label><br />
						</td>
					</tr>
						<tr>
							<td><hr class="border border-secondary w-100 ms-4 my-2 mx-auto"/></td>
							<td><hr class="border border-secondary w-75 my-4 me-5 mx-auto"/></td>
						</tr>
					<tr>
						<td class="formLabelRequired align-middle my-2"><fmt:message key="emport.indent" /></td>
						<td><input class="w-75 form-control form-control-sm my-2" type="text" id="prettyIndent" value="3" class="formVeryShort" /></td>
					</tr>
					<tr>
						<td class="formLabelRequired align-middle my-2"><fmt:message key="emport.pointValuesMax" /></td>
						<td>
							<select class="w-50 form-select form-select-sm my-2" id="pointValuesMax">
								<option value="100" />100</option>
								<option value="500" />500</option>
								<option value="1000" />1000</option>
								<option value="10000" />10000</option>
								<option value="100000" />100000</option>
								<option value="1000000" />1000000</option>
							</select>
						</td>
					</tr>
					<tr>
						<td colspan="2" align="center">
							<button id="exportJsonBtn" type="button" class="btn btn-primary custom-btn-blue m-3" onclick="doExportJson()"><fmt:message key="emport.exportJson"/></button>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<p></p>
							<div style="float: none; border-bottom-width: 0; border-left-width: 0; border-right-width: 0;">
								<p><hr class="border border-secondary w-75 my-4 ms-5 mx-auto"/></p>
								<table class="w-100">
									<tr>
										<td><span class="smallTitle"><fmt:message key="emport.import" /></span></td>
									</tr>
									<tr>
										<td>
											<fmt:message key="emport.importInstruction" />
											<button id="importJsonBtn" type="button" class="btn btn-primary custom-btn-blue ms-3" onclick="doImport()"><fmt:message key="emport.import"/></button>
											<button id="cancelBtn" type="button" class="btn btn-primary custom-btn-blue ms-3" onclick="importCancel()" disabled="disabled"><fmt:message key="common.cancel"/></button>
										</td>
									</tr>
									<tbody id="importMessages"></tbody>
									<tr>
										<td id="alternateMessage"></td>
									</tr>
								</table>
							</div>
						</td>
					</tr>
				</table>
			</div>
		</div>
		<div class="col-md-6">
			<div class="right-box my-3">
				<table class="w-100 m-3">
					<tr>
						<td><span class="smallTitle"><fmt:message key="emport.exportProjectTitle" /></span> <tag:help id="exportProject" /></td>
					</tr>
					<tr>
						<td><label class="align-middle m-2" for="projectName"><fmt:message key="emport.projectName" /></label> <input class="w-75 form-control form-control-sm my-2" type="text" id="projectName" value="${instanceDescriptionHeader}" /><br /></td>
					</tr>
					<tr>
						<td><label class="align-middle m-2" for="projectDescription"><fmt:message key="emport.projectDescription" /></label><br />
						<textarea class="form-control mb-3 w-75" id="projectDescription" rows="4" cols="50"/></textarea>
						<%-- <textarea id="projectDescription" rows="4" cols="50"></textarea> --%>
						</td>
					</tr>
					<tr>
						<td><input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="includePointValues" /> <label class="align-middle m-2" for="includePointValues"><fmt:message key="emport.includePointValues" /></label><br /> <input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="includeUploadsFolder" /> <label class="align-middle m-2" for="includeUploadsFolder"><fmt:message key="emport.uploadsFolder" /></label><br /> <input class="form-check-input align-middle custom-checkbox my-2" type="checkbox" id="includeGraphicsFolder" /> <label class="align-middle m-2" for="includeGraphicsFolder"><fmt:message key="emport.graphicsFolder" /></label><br /></td>
					</tr>
					<tr>
						<td><label class="align-middle m-2" for="pointValuesMaxZip"><fmt:message key="emport.pointValuesMax" /></label> <select class="w-25 form-select form-select-sm my-2" id="pointValuesMaxZip">
								<option value="100" />100</option>
								<option value="500" />500</option>
								<option value="1000" />1000</option>
								<option value="10000" />10000</option>
								<option value="100000" />100000</option>
								<option value="1000000" />1000000</option>
							</select></td>
					</tr>
					<tr>
						<td><fmt:message key="emport.exportProjectInstruction" />
						<button id="exportBtn" type="button" class="btn btn-primary custom-btn-blue ms-3" onclick="doExport()" ><fmt:message key="emport.exportProject"/></button>
						<%-- <input id="exportBtn" type="button" value="<fmt:message key="emport.exportProject"/>" onclick="doExport()" /></td> --%>
					</tr>
					<tbody></tbody>
					<tr>
						<td></td>
					</tr>
					<tr>
						<td colspan="2">
							<p><hr class="border border-secondary w-75 my-4 mx-auto"/></p>
							<div>
								<p></p>
								<form method="POST" action="import_project.htm" enctype="multipart/form-data" onsubmit="return checkFileToImport();">
									<table class="w-100 m-3">
										<tr>
											<td><span class="smallTitle"><fmt:message key="emport.importProjectTitle" /></span> <tag:help id="importProject" /></td>
										</tr>
										<tr>
											<td><fmt:message key="emport.importProjectInstruction" /></td>
										</tr>
										<tr>
											<td class="d-flex align-items-center justify-content-start">
											<input class="form-control m-3 w-50" type="file" name="importFile" id="importFile" />
											<button type="submit" class="btn btn-primary custom-btn-blue" id="importBtn" ><fmt:message key="emport.send"/></button>
											<%-- <input id="importBtn" type="submit" value="<fmt:message key="emport.send"/>" /> --%>
											</td>
										</tr>
										<tr>
											<td></td>
										</tr>
									</table>
								</form>
							</div>
						</td>
					</tr>
				</table>
			</div>
		</div>
	</div>
</div>
<div class="container">
	<div class="row">
		<div class="col-md-12">
			<div class="right-box my-3">
				<div class="w-100 m-3">
					<div>
						<div><span class="smallTitle m-3"><fmt:message key="emport.data" /></span></div>
					</div>
					<div class="my-3 me-4">
						<%-- <span class="formLabelRequired align-middle my-2"><fmt:message key="emport.data"/></span> --%>
						<textarea class="form-control mb-3" id="emportData" rows="40" cols="150"/></textarea>
						<%-- <textarea rows="40" cols="150" id="emportData"></textarea> --%>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
</tag:page>
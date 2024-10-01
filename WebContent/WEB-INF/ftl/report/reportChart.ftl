<#--
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
-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html>
<head>
  <title><@fmt key="header.title"/></title>
  
  <!-- Meta -->
  <meta http-equiv="content-type" content="application/xhtml+xml;charset=utf-8"/>
  <meta http-equiv="Content-Style-Type" content="text/css" />
  <meta name="Copyright" content="&copy;©2012-${toYear} Scada-LTS"/>

  <!-- Bootstrap -->
  <link rel="stylesheet" href="assets/lib/bootstrap-5.3.3/css/bootstrap.min.css">
  <link rel="stylesheet" href="assets/lib/bootstrap-5.3.3/bootstrap-icons-1.11.3/font/bootstrap-icons.min.css">
  <script src="assets/lib/bootstrap-5.3.3/js/bootstrap.bundle.min.js"></script>
  
  <!-- Style -->
  <link rel="icon" href="images/favicon.ico"/>
  <link rel="shortcut icon" href="images/favicon.ico"/>
  <style type="text/css">
    .bod {
      margin: 10px;
      padding: 5px;
      background-color: #FFFFFF;
    }
    .bod, td, th {
      font-family: Verdana, Arial, Helvetica, sans-serif;
      font-size: 11px;
      color: #000000;
    }
    .pointName {
      color: #804000;
      font-size: 13px;
      font-weight: bold;
    }
    .label {
      font-weight: bold;
      text-align: right;
      padding-right: 10px;
    }
    .stats {
      background-color: #F0F0F0;
      vertical-align: top;
    }
    .rowHeader td {
      font-weight: bold;
      color: #FFFFFF;
      background-color: #F07800;
      text-align: center;
      white-space: nowrap;
      padding: 3px 10px 3px 10px;
    }
    .rowTable td, .rowAlt td {
      color: #000000;
      padding: 3px;
    }
    .rowTable td {
      background-color: #F0F0F0;
    }
    .rowAlt td {
      background-color: #DCDCDC;
    }
    .copyTitle {
      color: #804000;
      font-size: 10px;
    }
  </style>
</head>

<body>
<div class="bod">
  <table width="100%" cellspacing="0" cellpadding="0" border="0">
    <tr>
      <td>
        <table>
          <tr>
            <td colspan="2"><h1>${instance.name}</h1></td>
          </tr>
          <tr>
            <td class="label"><@fmt key="reports.runTimeStart"/></td>
            <td>${instance.prettyRunStartTime}</td>
          </tr>
          <tr>
            <td class="label"><@fmt key="reports.runDuration"/></td>
            <td>${instance.prettyRunDuration}</td>
          </tr>
          <tr>
            <td class="label"><@fmt key="reports.dateRange"/></td>
            <td>${instance.prettyReportStartTime} <@fmt key="reports.dateRangeTo"/> ${instance.prettyReportEndTime}</td>
          </tr>
          <tr>
            <td class="label"><@fmt key="reports.reportRecords"/></td>
            <td>${instance.prettyRecordCount}</td>
          </tr>
        </table>
      </td>
      <td valign="top" align="right"><img src="assets/logo.svg" alt="Logo Argos SCADA" style="width: 181px; height: 55px /></td>
    </tr>
  </table>

  <h2><@fmt key="reports.statistics"/></h2>
  <table cellspacing="5">
    <#assign col = 1/>
    <#list points as point>
      <#assign col = col + 1/>
      <#if col == 2><#assign col = 0/></#if>
      <#if col == 0><tr></#if>
      
      <td class="stats">
        <table>
          <tr><td colspan="2" class="pointName">${point.name}</td></tr>
          <tr>
            <td class="label"><@fmt key="reports.dataType"/></td>
            <td>${point.dataTypeDescription}</td>
          </tr>
          <#if point.startValue??>
            <tr>
              <td class="label"><@fmt key="common.stats.start"/></td>
              <td>${point.startValue}</td>
            </tr>
          </#if>
          <#if point.dataType == NUMERIC>
            <tr>
              <td class="label"><@fmt key="common.stats.min"/></td>
              <td>${point.analogMinimum} @ ${point.analogMinTime}</td>
            </tr>
            <tr>
              <td class="label"><@fmt key="common.stats.max"/></td>
              <td>${point.analogMaximum} @ ${point.analogMaxTime}</td>
            </tr>
            <tr>
              <td class="label"><@fmt key="common.stats.avg"/></td>
              <td>${point.analogAverage}</td>
            </tr>
            <tr>
              <td class="label"><@fmt key="common.stats.sum"/></td>
              <td>${point.analogSum}</td>
            </tr>
            <tr>
              <td class="label"><@fmt key="common.stats.count"/></td>
              <td>${point.analogCount}</td>
            </tr>
          <#elseif point.dataType == BINARY || point.dataType == MULTISTATE>
            <tr>
              <td colspan="2">
                <table>
                  <tr style="padding-top:15px">
                    <th><@fmt key="common.stats.value"/></th>
                    <th><@fmt key="common.stats.starts"/></th>
                    <th><@fmt key="common.stats.runtime"/></th>
                  </tr>
                  
                  <#list point.startsAndRuntimes as sar>
                    <tr>
                      <td>${sar.value}</td>
                      <td align="right">${sar.starts}</td>
                      <td align="right">${sar.runtime}</td>
                    </tr>
                  </#list>
                </table>
              </td>
            </tr>
          <#elseif point.dataType == ALPHANUMERIC || point.dataType == IMAGE>
            <tr>
              <td class="label"><@fmt key="common.stats.count"/></td>
              <td>${point.valueChangeCount}</td>
            </tr>
          </#if>
          <#if point.chartData>
            <tr>
              <td colspan="2"><img src="${inline}${point.chartPath}"/></td>
            </tr>
          </#if>
        </table>
      </td>
      
      <#if col == 1></tr></#if>
    </#list>
    <#if col < 1></tr></#if>
  </table>
  
  <#if chartName??>
    <h2><@fmt key="reports.consolidated"/></h2>
    <img src="${inline}${chartName}"/>
  </#if>
  
  <#if includeEvents>
    <h2><@fmt key="reports.events"/></h2>
    <#if events?size == 0>
      <@fmt key="events.emptyList"/>
    <#else>
      <table cellspacing="1" cellpadding="0" width="100%">
        <tr class="rowHeader">
          <td><@fmt key="reports.eventList.id"/></td>
          <td><@fmt key="common.alarmLevel"/></td>
          <td><@fmt key="common.activeTime"/></td>
          <td><@fmt key="reports.eventList.message"/></td>
          <td><@fmt key="reports.eventList.status"/></td>
          <td><@fmt key="events.acknowledged"/></td>
          <td><@fmt key="reports.eventList.ackUser"/></td>
        </tr>
        
        <#assign rowTable = 1/>
        <#list events as event>
          <#assign rowTable = rowTable + 1/>
          <#if rowTable == 2><#assign rowTable = 0/></#if>
          
          <tr class="rowTable<#if rowTable == 1>Alt</#if>">
            <td align="center">${event.id?c}</td>
            <td align="center">
              <#if event.alarmLevel == 0><i class="bi bi-flag-fill text-success" alt="<@fmt key="common.alarmLevel.none"/>"></i>
              <#elseif event.alarmLevel == 1><i class="bi bi-flag-fill text-primary" alt="<@fmt key="common.alarmLevel.info"/>"></i>
              <#elseif event.alarmLevel == 2><i class="bi bi-flag-fill text-warning" alt="<@fmt key="common.alarmLevel.urgent"/>"></i>
              <#elseif event.alarmLevel == 3><i class="bi bi-flag-fill text-orange" alt="<@fmt key="common.alarmLevel.critical"/>"></i>
              <#elseif event.alarmLevel == 4><i class="bi bi-flag-fill text-danger" alt="<@fmt key="common.alarmLevel.lifeSafety"/>"></i>
              <#else>(<@fmt key="common.alarmLevel.unknown"/>  ${event.alarmLevel})
              </#if>
            </td>
            <td>${event.fullPrettyActiveTimestamp}</td>
            <td>
              <b><@fmt message=event.message/></b>
              <#if event.eventComments??>
                <table cellspacing="0" cellpadding="0">
                  <#list event.eventComments as comment>
                    <tr>
                      <td valign="top" width="16"><i class="bi bi-chat-dots text-success" alt="<@fmt key="notes.note"/>"></i></td>
                      <td valign="top">
                        <span class="copyTitle">
                          ${comment.prettyTime} <@fmt key="notes.by"/>
                          <#if comment.username??>
                            ${comment.username}
                          <#else>
                            <@fmt key="common.deleted"/>
                          </#if>
                        </span><br/>
                        ${comment.comment}
                      </td>
                    </tr>
                  </#list>
                </table>
              </#if>
            </td>
            <td>
              <#if event.active>
                <@fmt key="common.active"/>
                <i class="bi bi-flag" alt="<@fmt key="common.active"/>"></i>
              <#elseif !event.rtnApplicable>
              <#else>
                ${event.fullPrettyRtnTimestamp} - <@fmt message=event.rtnMessage/>
              </#if>
            </td>
            <td>
              <#if event.acknowledged>
                ${event.fullPrettyAcknowledgedTimestamp}
                <@fmt message=event.ackMessage/>
              </#if>
            </td>
            <td>
              <#if event.acknowledgedByUsername??>
                ${event.acknowledgedByUsername}
              </#if>
            </td>
          </tr>
        </#list>
      </table>
    </#if>
  </#if>
  
  <#if includeUserComments>
    <h2><@fmt key="reports.pointComments"/></h2>
    <#if userComments?size == 0>
      <@fmt key="reports.pointComments.empty"/>
    <#else>
      <table cellspacing="0" cellpadding="0">
        <#list userComments as comment>
          <tr>
            <td valign="top" width="16"><i class="bi bi-chat-dots text-success" alt="<@fmt key="notes.note"/>"></i></td>
            <td valign="top">
              <span class="copyTitle">
                ${comment.prettyTime} <@fmt key="notes.by"/>
                <#if comment.username??>
                  ${comment.username},
                <#else>
                  <@fmt key="common.deleted"/>,
                </#if>
                '${comment.pointName}'
              </span><br/>
              ${comment.comment}
            </td>
          </tr>
        </#list>
      </table>
    </#if>
  </#if>
</div>

<table width="100%" cellspacing="0" cellpadding="0" border="0">
  <tr><td colspan="2">&nbsp;</td></tr>
  <tr>
    <td colspan="2" class="footer" align="center">&copy;2012-${toYear} Argos SCADA <@fmt key="footer.rightsReserved"/></td>
  </tr>
</table>

</body>
</html>
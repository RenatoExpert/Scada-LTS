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


<script type="text/javascript">
	compatible = false;

	function setFocus() {
		$("username").focus();
		BrowserDetect.init();
		$set(
			"browser",
			BrowserDetect.browser + " " + BrowserDetect.version + " <fmt:message key="login.browserOnPlatform"/> " + BrowserDetect.OS
		);
		if(checkCombo(BrowserDetect.browser, BrowserDetect.version, BrowserDetect.OS)) {
			$("browserImg").src = "images/accept.png";
			show("okMsg");
			compatible = true;
		} else {
			$("browserImg").src = "images/thumb_down.png";
			show("warnMsg");
		}
	}

	function nag() {
		if (!compatible)
			alert('<fmt:message key="login.nag"/>');
	}
</script>

<style>
	html {
		font-size:62.5%;
	}

	* {
		margin: 0;
		padding: 0;
	}

	ul, li {
		list-style: none;
	}

	input {
		border: none;
	}

	body {
		width: 144rem;
	}

	.scada-acesso-BFc {
		box-sizing: border-box;
		padding: 18.2rem 55rem 9.81rem 55rem;
		width: 100%;
		overflow: hidden;
		position: relative;
		align-items: center;
		display: flex;
		flex-direction: column;
		background-color: #fafafa;
	}

	.scada-acesso-BFc .argos-8q4 {
		margin-bottom: 6.5611rem;
		width: 28rem !important;
		height: 5.3293rem !important;
		object-fit: contain;
		vertical-align: top;
		flex-shrink: 0;
	}

	.scada-acesso-BFc .input-qUa {
		margin-bottom: 0.6rem;
		box-sizing: border-box;
		padding-bottom: 1.8rem;
		width: 100%;
		display: flex;
		flex-direction: column;
		flex-shrink: 0;
	}

	.scada-acesso-BFc .input-qUa .label-YGW {
		margin-bottom: 0.6rem;
		font-size: 1.6rem;
		font-weight: 400;
		line-height: 1.25;
		color: #555555;
		font-family: Inter, 'Source Sans Pro';
		white-space: nowrap;
		flex-shrink: 0;
	}

	.scada-acesso-BFc .input-qUa .content-Ef8 {
		box-sizing: border-box;
		padding: 1.4rem 1.6rem;
		width: 100%;
		height: 4.8rem;
		border: solid 0.1rem #888888;
		background-color: #fafafa;
		border-radius: 0.6rem;
		flex-shrink: 0;
		font-size: 1.6rem;
	}

	.scada-acesso-BFc .input-qUa .content-Ef8 .auto-group-wksg-NFY {
		margin-right: 25rem;
		width: 5.8rem;
		height: 100%;
		font-size: 1.6rem;
		font-weight: 400;
		line-height: 1.25;
		color: #111111;
		font-family: Inter, 'Source Sans Pro';
		white-space: nowrap;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.scada-acesso-BFc .input-oLr {
		margin-bottom: 2.2rem;
		box-sizing: border-box;
		padding-bottom: 1.8rem;
		width: 100%;
		display: flex;
		flex-direction: column;
		flex-shrink: 0;
	}

	.scada-acesso-BFc .input-oLr .label-99p {
		margin-bottom: 0.6rem;
		font-size: 1.6rem;
		font-weight: 400;
		line-height: 1.25;
		color: #555555;
		font-family: Inter, 'Source Sans Pro';
		white-space: nowrap;
		flex-shrink: 0;
	}

	.scada-acesso-BFc .input-oLr .content-4Gn {
		box-sizing: border-box;
		padding: 1.4rem 1.6rem;
		width: 100%;
		height: 4.8rem;
		border: solid 0.1rem #888888;
		background-color: #fafafa;
		border-radius: 0.6rem;
		flex-shrink: 0;
	}

	.scada-acesso-BFc .input-oLr .content-4Gn .auto-group-zyzv-zw8 {
		margin-right: 24.4rem;
		width: 6.4rem;
		height: 100%;
		font-size: 1.6rem;
		font-weight: 400;
		line-height: 1.25;
		color: #111111;
		font-family: Inter, 'Source Sans Pro';
		white-space: nowrap;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.scada-acesso-BFc .button-primary-rCe {
		margin: 0rem 8rem 4rem 8rem;
		width: calc(100% - 16rem);
		height: 5rem;
		font-size: 1.6rem;
		font-weight: 600;
		line-height: 1.125;
		color: #ffffff;
		font-family: Inter, 'Source Sans Pro';
		white-space: nowrap;
		display: flex;
		align-items: center;
		justify-content: center;
		background-color: #0050d3;
		border-radius: 10rem;
		flex-shrink: 0;
	}

	.scada-acesso-BFc .frame-2-5r6 {
		margin: 0rem 13.4rem 6.4rem 13.4rem;
		width: calc(100% - 26.8rem);
		display: flex;
		align-items: center;
		flex-shrink: 0;
	}

	.scada-acesso-BFc .frame-2-5r6 .ajuda-anr {
		margin-right: 0.8rem;
		width: 2rem;
		height: 2rem;
		object-fit: contain;
		vertical-align: top;
		flex-shrink: 0;
	}

	.scada-acesso-BFc .frame-2-5r6 .ajuda-726 {
		font-size: 1.6rem;
		font-weight: 500;
		line-height: 1.5;
		color: #111111;
		font-family: Inter, 'Source Sans Pro';
		white-space: nowrap;
		flex-shrink: 0;
	}

	.scada-acesso-BFc .frame-3-qin {
		margin: 0rem 0.75rem 0rem 0.85rem;
		width: calc(100% - 1.6rem);
		height: 2.1rem;
		display: flex;
		align-items: center;
		flex-shrink: 0;
	}

	.scada-acesso-BFc .frame-3-qin .c-circle-xoQ {
		margin: 0.25rem 0.8rem 0.25rem 0rem;
		width: 1.6rem;
		height: calc(100% - 0.5rem);
		background-size: cover;
		background-repeat: no-repeat;
		background-position: center;
		background-image: url('../assets/union.png');
		flex-shrink: 0;
	}

	.scada-acesso-BFc .frame-3-qin .argos-scada-all-rights-reserved-Gp6 {
		font-size: 1.4rem;
		font-weight: 400;
		line-height: 1.5;
		color: #555555;
		font-family: Inter, 'Source Sans Pro';
		white-space: nowrap;
		flex-shrink: 0;
	}
</style>

<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Inter%3A400%2C500%2C600"/>
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro%3A400%2C500%2C600"/>

<tag:page onload="setFocus">

	<div class="scada-acesso-BFc">
		<img class="argos-8q4" src="images/login-assets/argos.png"/>
		<form name="f" action="login.htm" method="post" onclick="nag()">
			<div class="input-qUa">
				<p class="label-YGW">ID de Acesso</p>
				<input id="username" type="text" name="username" value="${login.username}" maxlength="40" class="content-Ef8"/>
			</div>
			<div class="input-oLr">
				<p class="label-99p">Senha</p>
				<input id="password" type="password" name="password" value="${login.password}" maxlength="20" class="content-4Gn"/>
			</div>
			<input class="button-primary-rCe" type="submit" value="Entrar"/>
			<div class="frame-2-5r6">
				<img class="ajuda-anr"
					src="images\login-assets\ajuda.png"
					alt=""/>
				<a href="#" class="ajuda-726">Ajuda</a>
			</div>
			<div class="formError">
				<c:if test="${not empty SPRING_SECURITY_LAST_EXCEPTION.message}">
					<div class="error">
						<c:out value="${SPRING_SECURITY_LAST_EXCEPTION.message}" />
					</div>
				</c:if>
			</div>
		</form>
		<div class="frame-3-qin">
			<div class="c-circle-xoQ"></div>
			<p class="argos-scada-all-rights-reserved-Gp6">2021 - 2024 Argos-Scada All rights reserved.</p>
		</div>
	</div>

<!--
	<div class="login-container">
		<div class="login-browser">
			<span id="browser"><fmt:message key="login.unknownBrowser"/></span>
			<img id="browserImg" src="images/magnifier.png" style="height: 10px;width: auto;"/>
			<span id="okMsg" style="display:none"><fmt:message key="login.supportedBrowser"/></span>
			<span id="warnMsg" style="display:none"><fmt:message key="login.unsupportedBrowser"/></span>
		</div>
		<div class="login-box">
			<form name="f" action="login.htm" method="post" onclick="nag()">
				<div class="form-box">
					<div class="formLabelRequired"><fmt:message key="login.userId"/></div>
						<div class="formField">
							<input id="username" type="text" name="username" value="${login.username}" maxlength="40"/>
						</div>
					</div>
				</div>
				<div class="form-box">
					<div class="formLabelRequired"><fmt:message key="login.password"/></div>
						<div class="formField">
							<input id="password" type="password" name="password" value="${login.password}" maxlength="20"/>
						</div>
					</div>
				</div>
				<div class="formError">
					<c:if test="${not empty SPRING_SECURITY_LAST_EXCEPTION.message}">
						<div class="error">
							<c:out value="${SPRING_SECURITY_LAST_EXCEPTION.message}" />
						</div>
					</c:if>
				</div>
				<div class="login-button" align="center">
					<input type="submit" value="<fmt:message key="login.loginButton"/>"/>
					<tag:help id="welcomeToMango"/>
				</div>
			</form>
		</div>
	</div>
</tag:page>

<script>
	document.getElementById("sltsFooter").remove();
	document.getElementById("mainHeader").remove();
	document.getElementById("subHeader").remove();
</script>


<%@ include file="/WEB-INF/jsp/include/tech.jsp" %>

<style>
	.login-access { width: 100%; margin: 0 auto; }
    #mainHeader, #subHeader {
        visibility: hidden;
    }
</style>

<tag:page onload="setFocus">

	<div class="login-access p-15 m-0">
		<div class="row">
			<div class="col-12 col-sm-2 col-md-3 col-lg-4 col-xl-4"></div>
			<div class="col-12 col-sm-5 col-md-5 col-lg-3 col-xl-3 ">
				<div class="row">
					<img class="mb-4" src="/Scada-LTS/assets/logo.svg" alt="Logo Argos SCADA" style="width: 340px; height: 108px;">

					<form name="f" action="login.htm" method="post" onclick="nag()" class="login-form">
						<label for="username" class="h6 font-weight-normal"><fmt:message key="login.userId"/></label>
						<input class="form-control" id="username" type="text" name="username" value="${login.username}" maxlength="40" autofocus>
						<label for="password" class="mt-4 h6 font-weight-normal"><fmt:message key="login.password"/></label>
						<input type="password" id="password" class="form-control" name="password" value="${login.password}" maxlength="20">
						<div class="formError">
							<c:if test="${not empty SPRING_SECURITY_LAST_EXCEPTION.message}">
								<div class="error">
									<c:out value="${SPRING_SECURITY_LAST_EXCEPTION.message}" />
								</div>
							</c:if>
						</div>
						<div class="text-center">
							<input type="submit" class="btn btn-primary btn-lg rounded-pill mt-4 w-100" value="<fmt:message key='login.loginButton'/>"/>
						</div>
					</form>
				</div>
			</div>
			<div class="col-12 col-sm-2 col-md-3 col-lg-4 col-xl-4"></div>
		</div>
	</div>
</tag:page>

<script type="text/javascript">
	compatible = false;

	function setFocus() {
		$("username").focus();
		BrowserDetect.init();

		$set("browser",
			BrowserDetect.browser + " " +
			BrowserDetect.version + " <fmt:message key="login.browserOnPlatform"/>" + BrowserDetect.OS
		);

		if (checkCombo(BrowserDetect.browser, BrowserDetect.version, BrowserDetect.OS)) {
			$("browserImg").src = "images/accept.png";
			show("okMsg");
			compatible = true;
		}
		else {
			$("browserImg").src = "images/thumb_down.png";
			show("warnMsg");
		}
	}

	function nag() {
		if (!compatible) {
			console.warn('<fmt:message key="login.nag"/>');
		}
	}
</script>

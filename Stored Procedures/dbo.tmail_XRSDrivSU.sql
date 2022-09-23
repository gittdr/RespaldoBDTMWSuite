SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_XRSDrivSU]
(
	@ID VARCHAR(8),
	@OrgTyp INT,
	@OrgLb INT,
	@LoginMisc INT,
	@HOSLB INT
)
AS 

/**
 * 
 * NAME:
 * dbo.tm_XRSDrivTM
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Gets driver TMWSuite component
 * 
 *
 * RETURNS:
 * driver TMWSuite component
 * 
 * 
 * PARAMETERS:
 *	@ID driver mpp_id
 *
 *
 * Change Log: 
 * rwolfe init 7/9/2013
 * 
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)

IF ISNULL(@OrgTyp,0) <0 OR ISNULL(@OrgTyp,0) > 10
	OR ISNULL(@OrgLb,0) <0 OR ISNULL(@OrgLb,0) > 2
	OR ISNULL(@LoginMisc,0) <0 OR ISNULL(@LoginMisc,0) > 4
	OR ISNULL(@HOSLB,0) <0 OR ISNULL(@HOSLB,0) > 2
	BEGIN
		RAISERROR('Invalid Types or Labels',16,1);
		RETURN;
	END
IF 	ISNULL(@OrgTyp,0) = 0 AND ISNULL(@OrgLb,0) != 0
	BEGIN
		RAISERROR('Relocated Feild Inconsistancy',16,1);
		RETURN;
	END
	

--out vars
DECLARE
	@Frist VARCHAR(40),
	@Middle VARCHAR(1),
	@Last VARCHAR(40),
	@LicenceNum VARCHAR(25),
	@AlternateP VARCHAR(20),
	@CurrentP VARCHAR(20),
	@Login VARCHAR(254),
	@OrgFull VARCHAR(50),
	@Active VARCHAR(6),
	@HOS VARCHAR(20),
	@TimeStamp DATETIME;

--tempvars	
DECLARE
	@orgAbr VARCHAR(6),
	@HOSAbr VARCHAR(6),
	@LBDeff VARCHAR(20);
	
SELECT @Frist = mpp_firstname, @Middle = mpp_middlename, @Last= mpp_lastname,@LicenceNum = mpp_licensenumber, 
@AlternateP = mpp_alternatephone, @CurrentP = mpp_currentphone,@Active = mpp_status,@HOSAbr = mpp_servicerule, @TimeStamp = dbo.manpowerprofile.mpp_updateon
FROM dbo.manpowerprofile WHERE mpp_id = @ID;

IF @LoginMisc = 1
	SELECT @Login = mpp_misc1 FROM dbo.manpowerprofile WHERE mpp_id = @ID;
ELSE IF @LoginMisc = 2
	SELECT @Login = mpp_misc2 FROM dbo.manpowerprofile WHERE mpp_id = @ID;
ELSE IF @LoginMisc = 3
	SELECT @Login = mpp_misc3 FROM dbo.manpowerprofile WHERE mpp_id = @ID;
ELSE IF @LoginMisc = 4
	SELECT @Login = mpp_misc4 FROM dbo.manpowerprofile WHERE mpp_id = @ID;

--get Orgnization
IF @OrgTyp > 0 
BEGIN
	DECLARE @mppFeild VARCHAR(50), @lbFeild VARCHAR(50), @statement NVARCHAR(500),@prams NVARCHAR(500);
	
	IF(@OrgTyp > 0 AND @OrgTyp < 5)
	BEGIN
		SET @mppFeild = 'mpp_type' + CAST(@OrgTyp AS VARCHAR(2));
		SET @LbDeff = 'DrvType' + CAST(@OrgTyp AS VARCHAR(2));
	END
	ELSE IF (@OrgTyp = 5)
	BEGIN
		SET @mppFeild = 'mpp_company';
		SET @LbDeff = 'Company';
	END
	ELSE IF	(@OrgTyp = 6)
	BEGIN
		SET @mppFeild = 'mpp_division';
		SET @LbDeff = 'Division';
	END
	ELSE IF (@OrgTyp = 7)
	BEGIN
		SET @mppFeild = 'mpp_teamleader';
		SET @LbDeff = 'TeamLeader';
	END
	ELSE IF (@OrgTyp = 8)
	BEGIN
		SET @mppFeild = 'mpp_fleet';
		SET @LbDeff = 'Fleet';
	END
	ELSE IF (@OrgTyp = 9)
	BEGIN
		SET @mppFeild = 'mpp_terminal';
		SET @LbDeff = 'Terminal';
	END
	ELSE IF (@OrgTyp = 10)
	BEGIN
		SET @mppFeild = 'mpp_domicile';
		SET @LbDeff = 'Domicile';
	END

	SET @statement ='SELECT @orgAbr=' + @mppFeild +' FROM dbo.manpowerprofile WHERE mpp_id = @ID;'
	SET @prams = '@orgAbr varchar(6) OUTPUT, @ID varchar(8)'
	
	exec sp_executesql @statement,@prams,@ID=@ID,@orgAbr = @orgAbr OUTPUT;
	
	IF @OrgLb = 1
		SELECT @OrgFull = label_extrastring1 FROM dbo.labelfile WHERE abbr = @orgAbr AND labeldefinition = @LBDeff;
	ELSE IF @OrgLb = 2
		SELECT @OrgFull = label_extrastring2 FROM dbo.labelfile WHERE abbr = @orgAbr AND labeldefinition = @LBDeff;
	ELSE IF @OrgLb = 0
		SELECT @OrgFull = name FROM dbo.labelfile WHERE abbr = @orgAbr AND labeldefinition = @LBDeff;
	
END	
--end Orgaization

--Start Service Rule
IF @HOSLB = 1
	SELECT @HOS = label_extrastring1 FROM dbo.labelfile WHERE abbr = @HOSAbr AND labeldefinition = 'ServiceRule';
ELSE IF @HOSLB = 2
	SELECT @HOS = label_extrastring2 FROM dbo.labelfile WHERE abbr = @HOSAbr AND labeldefinition = 'ServiceRule';
ELSE IF @HOSLB = 0
	SELECT @HOS = name FROM dbo.labelfile WHERE abbr = @HOSAbr AND labeldefinition = 'ServiceRule';
--End ServicRule

SELECT 'TimeStamp'=@TimeStamp,'FirstN'=@Frist,'MiddleI'=@Middle,'LastN'=@Last,'Licence'=@LicenceNum,'AltPohne'=@AlternateP,
'CurPhone'=@CurrentP,'Login'=@Login,'Org'=@OrgFull,'Active'=@Active,'XRSHOS'=@HOS, 'MPPHOS'=@HOSAbr;

GRANT EXECUTE ON dbo.tmail_XRSDrivSU TO PUBLIC
GO

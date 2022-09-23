SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_XRSTrcSU]
(
	@ID VARCHAR(8),
	@TGTMis INT ,
	@OrgTyp INT,
	@OrgLb INT,
	@TruckTyp INT,
	@TruckTypLB INT,
	@OwnerOpTyp INT,
	@OwnerOpLB INT,
	@StrightTyp INT,
	@StrightLB INT,
	@BirthLoc INT,
	@BirthLB INT
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
 * Gets Truck TMWSuite component
 * 
 *
 * RETURNS:
 * Truck TMWSuite component
 * 
 * 
 * PARAMETERS:
 *	@ID Truck trc_id
 *
 *
 * Change Log: 
 * rwolfe init 7/9/2013
 * 
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)

IF	ISNULL(@TGTMis,0) <0 OR ISNULL(@TGTMis,0) >4
	OR ISNULL(@OrgTyp,0) <0 OR ISNULL(@OrgTyp,0) > 9
	OR ISNULL(@OrgLb,0) <0 OR ISNULL(@OrgLb,0) > 3
	OR ISNULL(@TruckTyp,0) <0 OR ISNULL(@TruckTyp,0) > 4
	OR ISNULL(@TruckTypLB,0) <0 OR ISNULL(@TruckTypLB,0) > 3
	OR ISNULL(@OwnerOpTyp,0) <0 OR ISNULL(@OwnerOpTyp,0) > 9
	OR ISNULL(@OwnerOpLB,0) <0 OR ISNULL(@OwnerOpLB,0) > 3
	OR ISNULL(@StrightTyp,0) <0 OR ISNULL(@StrightTyp,0) > 5
	OR ISNULL(@StrightLB,0) < 0 OR ISNULL(@StrightLB, 0) > 3
	OR ISNULL(@BirthLoc,0) < 0 OR ISNULL(@BirthLoc,0) > 4
	OR ISNULL(@BirthLB,0) < 0 OR ISNULL(@BirthLB,0) > 3
	BEGIN
		RAISERROR('Invalid parmameters',16,1);
		RETURN;
	END
	


--final output
DECLARE 
	@TGT VARCHAR(20),
	@OrgName VARCHAR(20),
	@OrgSid VARCHAR(20),
	@LicPlate VARCHAR(12),
	@Active INT,
	@VIN VARCHAR(20),
	@Manufact VARCHAR(8),
	@Model VARCHAR(8),
	@FuelDraw INT,
	@GWeght INT,
	@Stright VARCHAR(20),
	@Type VARCHAR(20),
	@TimeStamp DATETIME,
	@OrgFull VARCHAR(50),
	@OwnerOpFull VARCHAR(50),
	@birth VARCHAR(50),
	@MCTypeFull1 VARCHAR(150),
	@MCTypeFull2 VARCHAR(50),
	@MCTypeFull3 VARCHAR(50);
	
--temp vars
DECLARE
	@ActTemp VARCHAR(6),
	@orgAB VARCHAR(6),
	@StrightAB VARCHAR(6),
	@TypeAB VARCHAR(6),
	@LBDeff VARCHAR(20),
	@comTyp VARCHAR(6),
	@birthAB VARCHAR(50);

SELECT @LicPlate = trc_licnum,@ActTemp = trc_status,@StrightAB = trc_require_drvtrl,@VIN =trc_serial,@Manufact = trc_make,@TimeStamp = trc_updatedon,
@Model = trc_model,@FuelDraw = trc_tank_capacity,@GWeght = trc_grosswgt, @comTyp = trc_commethod FROM dbo.tractorprofile WHERE trc_number = @ID;

--mcom type
SELECT @MCTypeFull1 = name, @MCTypeFull2 = label_extrastring1, @MCTypeFull3 = label_extrastring2 FROM dbo.labelfile WHERE abbr = @comTyp AND labeldefinition = 'ComType';
SET @MCTypeFull1 = ISNULL(@MCTypeFull1,'')+ ',' + ISNULL(@MCTypeFull2,'')+ ',' + ISNULL(@MCTypeFull3,'');

--TGT
IF @TGTMis = 1
	SELECT @TGT = trc_misc1 FROM dbo.tractorprofile WHERE trc_number = @ID;
ELSE IF @TGTMis = 2
	SELECT @TGT = trc_misc2 FROM dbo.tractorprofile WHERE trc_number = @ID;
ELSE IF @TGTMis = 3
	SELECT @TGT = trc_misc3 FROM dbo.tractorprofile WHERE trc_number = @ID;
ELSE IF @TGTMis = 4
	SELECT @TGT = trc_misc4 FROM dbo.tractorprofile WHERE trc_number = @ID;

--get Orgnization
IF @OrgTyp != 0 OR @OrgTyp = 10
BEGIN
	DECLARE @mppFeild VARCHAR(50), @statement NVARCHAR(500),@prams NVARCHAR(500),@orgAbr VARCHAR(6);
	
	IF(@OrgTyp > 0 AND @OrgTyp < 5)
	BEGIN
		SET @mppFeild = 'trc_type' + CAST(@OrgTyp AS VARCHAR(2));
		SET @LbDeff = 'TrcType' + CAST(@OrgTyp AS VARCHAR(2));
	END
	ELSE IF (@OrgTyp = 5)
	BEGIN
		SET @mppFeild = 'trc_company';
		SET @LbDeff = 'Company';
	END
	ELSE IF	(@OrgTyp = 6)
	BEGIN
		SET @mppFeild = 'trc_division';
		SET @LbDeff = 'Division';
	END
	ELSE IF (@OrgTyp = 7)
	BEGIN
		SET @mppFeild = 'trc_teamleader';
		SET @LbDeff = 'TeamLeader';
	END
	ELSE IF (@OrgTyp = 8)
	BEGIN
		SET @mppFeild = 'trc_fleet';
		SET @LbDeff = 'Fleet';
	END
	ELSE IF (@OrgTyp = 9)
	BEGIN
		SET @mppFeild = 'trc_terminal';
		SET @LbDeff = 'Terminal';
	END

	SET @statement ='SELECT @orgAbr=' + @mppFeild +' FROM tractorprofile WHERE trc_number = @ID;'
	SET @prams = '@orgAbr varchar(6) OUTPUT, @ID varchar(8)'
	
	exec sp_executesql @statement,@prams,@ID=@ID,@orgAbr = @orgAbr OUTPUT;
	
	IF @OrgLb = 1
		SELECT @OrgFull = label_extrastring1 FROM dbo.labelfile WHERE abbr = @orgAbr AND labeldefinition = @LbDeff;
	ELSE IF @OrgLb = 2
		SELECT @OrgFull = label_extrastring2 FROM dbo.labelfile WHERE abbr = @orgAbr AND labeldefinition = @LbDeff;
	ELSE IF @OrgLb = 0
		SELECT @OrgFull = name FROM dbo.labelfile WHERE abbr = @orgAbr AND labeldefinition = @LbDeff;
	
END
--end Orgaization

SET @LbDeff = '';

--get Owner Operator
IF @OwnerOpTyp != 0 OR @OwnerOpTyp = 10
BEGIN
	DECLARE @ownOpFeild VARCHAR(50), @statement2 NVARCHAR(500),@prams2 NVARCHAR(500),@orgAbr2 VARCHAR(6);
	
	IF(@OwnerOpTyp > 0 AND @OwnerOpTyp < 5)
	BEGIN
		SET @ownOpFeild = 'trc_type' + CAST(@OwnerOpTyp AS VARCHAR(2));
		SET @LbDeff = 'TrcType' + CAST(@OwnerOpTyp AS VARCHAR(2));
	END
	ELSE IF (@OwnerOpTyp = 5)
	BEGIN
		SET @ownOpFeild = 'trc_company';
		SET @LbDeff = 'Company';
	END
	ELSE IF	(@OwnerOpTyp = 6)
	BEGIN
		SET @ownOpFeild = 'trc_division';
		SET @LbDeff = 'Division';
	END
	ELSE IF (@OwnerOpTyp = 7)
	BEGIN
		SET @ownOpFeild = 'trc_teamleader';
		SET @LbDeff = 'TeamLeader';
	END
	ELSE IF (@OwnerOpTyp = 8)
	BEGIN
		SET @ownOpFeild = 'trc_fleet';
		SET @LbDeff = 'Fleet';
	END
	ELSE IF (@OwnerOpTyp = 9)
	BEGIN
		SET @ownOpFeild = 'trc_terminal';
		SET @LbDeff = 'Terminal';
	END

	SET @statement2 ='SELECT @orgAbr2=' + @ownOpFeild +' FROM tractorprofile WHERE trc_number = @ID;'
	SET @prams2 = '@orgAbr2 varchar(6) OUTPUT, @ID varchar(8)'
	
	exec sp_executesql @statement2,@prams2,@ID=@ID,@orgAbr2 = @orgAbr2 OUTPUT;
	
	IF @OwnerOpLB = 1
		SELECT @OwnerOpFull = label_extrastring1 FROM dbo.labelfile WHERE abbr = @orgAbr2 AND labeldefinition = @LbDeff;
	ELSE IF @OwnerOpLB = 2
		SELECT @OwnerOpFull = label_extrastring2 FROM dbo.labelfile WHERE abbr = @orgAbr2 AND labeldefinition = @LbDeff;
	ELSE IF @OwnerOpLB = 0
		SELECT @OwnerOpFull = name FROM dbo.labelfile WHERE abbr = @orgAbr2 AND labeldefinition = @LbDeff;
	
END
--end Owner Operator


--type type
IF @TruckTyp > 0 
BEGIN
	IF @TruckTyp =1
	BEGIN
		SELECT @TypeAB = trc_type1 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType1'
	END
	ELSE IF @TruckTyp =2
	BEGIN
		SELECT @TypeAB = trc_type2 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType2'
	END
	ELSE IF @TruckTyp =3
	BEGIN
		SELECT @TypeAB = trc_type3 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType3'
	END
	ELSE IF @TruckTyp = 4
	BEGIN
		SELECT @TypeAB = trc_type4 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType4'
	END
	
	IF @TruckTypLB = 1
		SELECT @Type = label_extrastring1 FROM dbo.labelfile WHERE abbr = @TypeAB AND labeldefinition = @LBDeff;
	ELSE IF	@TruckTypLB = 2
		SELECT @Type = label_extrastring2 FROM dbo.labelfile WHERE abbr = @TypeAB AND labeldefinition = @LBDeff;
	ELSE IF @TruckTypLB = 0 
		SELECT @Type = name FROM dbo.labelfile WHERE abbr = @TypeAB AND labeldefinition = @LBDeff;
	
END

--stright truck stuff
IF @StrightTyp > 0 --this case is important because of type 5
BEGIN
	IF @StrightTyp = 1
	BEGIN
		SELECT @StrightAB = trc_type1 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType1'
	END
	ELSE IF @StrightTyp = 2
	BEGIN
		SELECT @StrightAB = trc_type2 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType2'
	END
	ELSE IF @StrightTyp = 3
	BEGIN
		SELECT @StrightAB = trc_type3 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType3'
	END
		ELSE IF @StrightTyp = 4
	BEGIN
		SELECT @StrightAB = trc_type4 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType4'
	END
	ELSE IF @StrightTyp = 5
	BEGIN
		SET @LBDeff = 'trcRequiresDrvTrl'
	END

	IF @StrightLB = 1
		SELECT @Stright = label_extrastring1 FROM dbo.labelfile WHERE abbr = @StrightAB AND labeldefinition = @LBDeff;
	ELSE IF	@StrightLB = 2
		SELECT @Stright = label_extrastring2 FROM dbo.labelfile WHERE abbr = @StrightAB AND labeldefinition = @LBDeff;
	ELSE IF @StrightLB = 0
		SELECT @Stright = name FROM dbo.labelfile WHERE abbr = @StrightAB AND labeldefinition = @LBDeff;
	
END 


--Birth
IF @BirthLoc > 0 
BEGIN
	IF @BirthLoc =1
	BEGIN
		SELECT @birthAB = trc_type1 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType1'
	END
	ELSE IF @BirthLoc =2
	BEGIN
		SELECT @birthAB = trc_type2 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType2'
	END
	ELSE IF @BirthLoc =3
	BEGIN
		SELECT @birthAB = trc_type3 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType3'
	END
	ELSE IF @BirthLoc = 4
	BEGIN
		SELECT @birthAB = trc_type4 FROM dbo.tractorprofile WHERE trc_number = @ID;
		SET @LBDeff = 'TrcType4'
	END
	
	IF @BirthLB = 1
		SELECT @birth = label_extrastring1 FROM dbo.labelfile WHERE abbr = @birthAB AND labeldefinition = @LBDeff;
	ELSE IF	@BirthLB = 2
		SELECT @birth = label_extrastring2 FROM dbo.labelfile WHERE abbr = @birthAB AND labeldefinition = @LBDeff;
	ELSE IF @BirthLB = 0 
		SELECT @birth = name FROM dbo.labelfile WHERE abbr = @birthAB AND labeldefinition = @LBDeff;
	
END


SELECT 'TimeStamp'=@TimeStamp,'TGT'=@TGT,'Org'=@OrgFull,'LicPlate'=@LicPlate,'Active'=@ActTemp,'VIN'=@VIN,'Manufact'=@Manufact,
'Model'=@Model,'FuelDraw'=@FuelDraw,'GWeght'=@GWeght,'Stright'=@Stright,'Type'=@Type,'OwnerOperator'=@OwnerOpFull,'HasBirth'=@birth,'CommType' = @MCTypeFull1;

GO
GRANT EXECUTE ON  [dbo].[tmail_XRSTrcSU] TO [public]
GO

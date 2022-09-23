SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[tmail_addtrailer] 
(
	@TrailerNumber varchar(30), --1
	@CurrentHub varchar(20),
	@ILTScac varchar(4),
	@ILT varchar(1),
	@TrailerID varchar(20),--5
	@CompanyID varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
	@Owner varchar(20),
	@SerialNo varchar(20),
	@Company varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
	@Fleet varchar(10), --10
	@Division varchar(10),
	@Terminal varchar(10),
	@TrailerType1 varchar(10),
	@TrailerType2 varchar(10),
	@TrailerType3 varchar(10), --15
	@TrailerType4 varchar(10),
	@Flags varchar(10)
)

AS

/*

Flags
	1 = No error on duplicate (Ignore Duplicates)
	2 = Split Trailer Number Into SCAC and TrlNumber if needed
	4 = Error on new trailer
	8 = Use Trl_id
	16 = Suppressed Comma

*/

DECLARE @iCurrentHub as int
DECLARE @sTrailerType1 as varchar(8)
DECLARE @sTrailerType2 as varchar(8)
DECLARE @sTrailerType3 as varchar(8)
DECLARE @sTrailerType4 as varchar(8)
DECLARE @sCompany as varchar(25) --PTS 61189 CMP_ID INCREASE LENGTH TO 25
DECLARE @sFleet as varchar(8)
DECLARE @sDivision as varchar(8)
DECLARE @sTerminal as varchar(8)
DECLARE @sCompanyID as varchar(25) --PTS 61189 CMP_ID INCREASE LENGTH TO 25
DECLARE @sTrailerID as varchar(20)
DECLARE @sILTScac as varchar(4)
DECLARE @sOwner as varchar(20)
DECLARE @dMsgDate as datetime
DECLARE @sTrailerNumberForComparison as varchar(30)

SET @dMsgDate = GETDATE()

IF ISNULL(@TrailerNumber,'')=''
BEGIN
	RAISERROR('Missing Trailer Number.', 16, 1)
	RETURN
END

IF EXISTS (SELECT NULL 
			FROM TrailerProfile (NOLOCK)
			WHERE trl_number = @TrailerNumber)
BEGIN
	IF @Flags & 1 <> 0
	BEGIN
		SELECT @TrailerNumber as TrailerID  --No error on duplicate flag set
		RETURN
	END
	ELSE
	BEGIN
		RAISERROR('Duplicate Trailer ID Found: %s', 16, 1, @TrailerNumber)
		RETURN
	END
END
ELSE
BEGIN
	IF @Flags & 8 <> 0
	BEGIN
		IF @Flags & 16 <> 0 SET @sTrailerNumberForComparison = LEFT(@TrailerNumber,4)+','+SUBSTRING(@TrailerNumber, 5, 20)
		IF EXISTS (SELECT NULL 
					FROM TrailerProfile (NOLOCK)
					WHERE trl_id = @sTrailerNumberForComparison)
		BEGIN
			IF @Flags & 1 <> 0
			BEGIN
				SELECT @sTrailerNumberForComparison as TrailerID  --No error on duplicate flag set
				RETURN
			END
			ELSE
			BEGIN
				RAISERROR('Duplicate Trailer ID Found: %s', 16, 1, @sTrailerNumberForComparison)
				RETURN
			END
		END
	END
	
	--Error on insert new
	IF @Flags & 4 <> 0
	BEGIN
		RAISERROR('Trailer Not On File (%s).', 16, 1, @TrailerNumber)
		RETURN
	END
	--Trailer Not On File, So Add Now
		
	--If Flag 2 is set, Validate Trailer Number Length and split if necessary
	IF @Flags & 2 <> 0 AND LEN(@TrailerNumber)>8  
	BEGIN
		SET @ILTScac = LEFT(@TrailerNumber,4)
		SET @TrailerNumber = SUBSTRING(@TrailerNumber, 5, 99)
	END
	--Validate Hub, If Provided
	IF ISNULL(@CurrentHub,'')<>''
	BEGIN
		IF ISNUMERIC(@CurrentHub)=0
		BEGIN
			RAISERROR('Invalid Current Hub (%s) for Trailer (%s)', 16, 1, @CurrentHub, @TrailerNumber)
			RETURN
		END
		ELSE
		BEGIN
			SET @iCurrentHub = Convert(int, @CurrentHub)
		END
	END
	ELSE
	BEGIN
		SET @iCurrentHub = 0
	END

	SET @sTrailerType1 = 'UNK'
	SET @sTrailerType2 = 'UNK'
	SET @sTrailerType3 = 'UNK'
	SET @sTrailerType4 = 'UNK'
	SET @sCompany = 'UNK'
	SET @sFleet = 'UNK'
	SET @sDivision = 'UNK'
	SET @sTerminal = 'UNK'
	SET @sCompanyID = 'UNKNOWN'
	SET @sTrailerID = @TrailerNumber
	SET @sILTScac = NULL
	SET @sOwner = 'UNKNOWN'

	IF ISNULL(@TrailerType1,'') <> ''
		SET @sTrailerType1 = @TrailerType1
	IF ISNULL(@TrailerType2,'') <> ''
		SET @sTrailerType2 = @TrailerType2
	IF ISNULL(@TrailerType3,'') <> ''
		SET @sTrailerType3 = @TrailerType3
	IF ISNULL(@TrailerType4,'') <> ''
		SET @sTrailerType4 = @TrailerType4
	IF ISNULL(@Company,'') <> ''
		SET @sCompany = @Company
	IF ISNULL(@Fleet,'') <> ''
		SET @sFleet = @Fleet
	IF ISNULL(@Division,'') <> ''
		SET @sDivision = @Division
	IF ISNULL(@Terminal,'') <> ''
		SET @sTerminal = @Terminal
	IF ISNULL(@CompanyID,'') <> ''
		SET @sCompanyID = @CompanyID
	IF ISNULL(@ILTScac,'') <> ''
		SET @sTrailerID = @ILTScac + ','+ @TrailerNumber
	IF ISNULL(@ILTScac,'') <> ''
		SET @sILTScac = @ILTScac 
	IF ISNULL(@Owner,'') <> ''
		SET @sOwner = @Owner 
	
INSERT INTO TrailerProfile 
(
	trl_number, --1
	trl_owner,
    trl_make,
	trl_model,
    trl_currenthub,
	trl_type1,
	trl_type2,
	trl_type3,
	trl_type4,
	trl_year, --10
    trl_startdate,
    trl_retiredate,
    trl_mpg,
    trl_company,
	trl_fleet,
	trl_division,
	trl_terminal,
	cmp_id,
	cty_code, 
    trl_ilt,--20
	trl_mtwgt,
    trl_grosswgt,
	trl_axles,
	trl_ht,
    trl_len,
    trl_wdth,
    trl_licstate,
    trl_licnum,
    trl_status, 
    trl_serial,--30
    trl_dateacquired,
    trl_origcost,
    trl_opercostmile,
    trl_sch_date,            
	trl_sch_cmp_id,
	trl_sch_city,
	trl_sch_status,
	trl_avail_date,
	trl_avail_cmp_id,
	trl_avail_city,--40
	trl_fix_record,
	trl_last_stop,
	trl_misc1,
	trl_misc2,
	trl_misc3,                                                                                                                                                                                                                                                      
	trl_misc4,                                                                                                                                                                                                                                                      
	trl_id,        
	trl_cur_mileage, 
	trl_bmp_pathname,                                                                                                                                                                                                                                              
	--timestamp    ,   --50   
	trl_actg_type,
	 trl_ilt_scac ,
	trl_updatedby  ,                                                                                                                                                                                                                                                  
	trl_updateon  ,          
	trl_tareweight ,        
	trl_kp_to_axle1,        
	trl_axle1_to_axle2 ,    
	trl_axle2_to_axle3  ,   
	trl_axle3_to_axle4 ,    
	trl_comprt1_size_wet,--60 
	trl_comprt2_size_wet, 
	trl_comprt3_size_wet ,
	trl_comprt4_size_wet ,
	trl_comprt5_size_wet ,
	trl_comprt6_size_wet ,
	trl_comprt1_uom_wet ,
	trl_comprt2_uom_wet ,
	trl_comprt3_uom_wet ,
	trl_comprt4_uom_wet ,
	trl_comprt5_uom_wet ,--70
	trl_comprt6_uom_wet ,
	trl_comprt1_bulkhead ,
	trl_comprt2_bulkhead ,
	trl_comprt3_bulkhead ,
	trl_comprt4_bulkhead ,
	trl_comprt5_bulkhead ,
	trl_tareweight_uom ,
	trl_kp_to_axle1_uom ,
	trl_axle1_to_axle2_uom ,
	trl_axle2_to_axle3_uom ,--80
	trl_axle3_to_axle4_uom ,
	trl_createdate ,         
	trl_pupid     ,
	trl_axle4_to_axle5,     
	trl_axle4_to_axle5_uom, 
	trl_lastaxle_to_rear   ,
	trl_lastaxle_to_rear_uom, 
	trl_nose_to_kp         ,
	trl_nose_to_kp_uom ,
	trl_total_no_of_compartments , --90
	trl_total_trailer_size_wet ,
	trl_uom_wet ,
	trl_total_trailer_size_dry ,
	trl_uom_dry ,
	trl_comprt1_size_dry ,
	trl_comprt2_size_dry ,
	trl_comprt3_size_dry ,
	trl_comprt4_size_dry ,
	trl_comprt5_size_dry ,
	trl_comprt6_size_dry ,--100
	trl_comprt1_uom_dry ,
	trl_comprt2_uom_dry ,
	trl_comprt3_uom_dry ,
	trl_comprt4_uom_dry ,
	trl_comprt5_uom_dry ,
	trl_comprt6_uom_dry ,
	trl_bulkhead_comprt1_thick ,
	trl_bulkhead_comprt2_thick ,
	trl_bulkhead_comprt3_thick ,
	trl_bulkhead_comprt4_thick ,--110
	trl_bulkhead_comprt5_thick ,
	trl_bulkhead_comprt1_thick_uom ,
	trl_bulkhead_comprt2_thick_uom ,
	trl_bulkhead_comprt3_thick_uom ,
	trl_bulkhead_comprt4_thick_uom ,
	trl_bulkhead_comprt5_thick_uom ,
	trl_quickentry ,
	trl_wash_status ,
	trl_manualupdate ,
	trl_exp1_date     ,--120      
	trl_exp2_date      ,     
	trl_last_cmd ,
	trl_last_cmd_ord ,
	trl_last_cmd_date ,      
	trl_palletcount ,
	trl_customer_flag, 
	trl_billto_parent ,
	trl_booked_revtype1, 
	trl_next_event ,
	trl_next_cmp_id ,--130
	trl_next_city ,
	trl_next_state ,
	trl_next_region1, 
	trl_next_region2 ,
	trl_next_region3 ,
	trl_next_region4 ,
	trl_prior_event ,
	trl_prior_cmp_id ,
	trl_prior_city ,
	trl_prior_state ,--140
	trl_prior_region1, 
	trl_prior_region2 ,
	trl_prior_region3 ,
	trl_prior_region4 ,
	trl_accessorylist  ,                                                                                                                                                                                                                                           
	 trl_newused,
	 trl_gp_class    ,
	trl_worksheet_comment1        ,                               
	trl_worksheet_comment2         , --150                            
	 trl_loading_class ,
	trl_axlgrp1_tarewgt ,   
	trl_axlgrp1_grosswgt ,  
	trl_axlgrp2_tarewgt   , 
	trl_axlgrp2_grosswgt   ,
	trl_exp1_enddate        ,
	trl_exp2_enddate        ,
	trl_gps_desc             ,                                                                                                                                                                                                                                      
	 trl_gps_date            ,
	trl_gps_latitude ,--160
	trl_gps_longitude ,
	trl_gps_odometer ,
	trl_lifetimemileage,                     
	trl_branch   ,
	trl_height    ,         
	trl_width      ,        
	trl_liccountry  ,                                   
	trl_aceid  ,
	trl_aceidtype, 
	trl_email --170
)
VALUES
(
	@TrailerNumber,--1
	@sOwner,
	'UNK',
	'UNK',
	@iCurrentHub,
	@sTrailerType1,
	@sTrailerType2,
	@sTrailerType3,
	@sTrailerType4,
	NULL,--10
	@dMsgDate,
	'2049-12-31 23:59:00.000',
	0,       
	@sCompany,
	@sFleet,
	@sDivision,
	@sTerminal,
	@sCompanyID,
	0,
	'N',--20
	0,
	0,
	0,
	0,
	0,
	0,
	NULL,
	NULL,
	'AVL',
	NULL,--30
	NULL,
	0,
	0,
	NULL,
	'UNKNOWN',
	0,
	'AVL',
	@dMsgDate,
	'UNKNOWN',
	0,--40
	'N',
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	@sTrailerID,
	0,
	NULL,
	--timestamp,--50
	'N',
	@sILTScac,
	'TMAIL',
	@dMsgDate,
	0,
	0,
	0,
	0,
	0,
	0,--60
	0,
	0,
	0,
	0,
	0,
	'UNK',
	'UNK',
	'UNK',
	'UNK',
	'UNK',--70
	'UNK',
	'SINGLE',
	'SINGLE',
	'SINGLE',
	'SINGLE',
	'SINGLE',
	'UNK',
	'UNK',
	'UNK',
	'UNK',--80
	'UNK',
	@dMsgDate,
	'UNKNOWN',
	0,
	'UNK',
	0,
	'UNK',	
	0,
	'UNK',
	0,--90
	0,
	'UNK',
	0,
	'UNK',
	0,
	0,
	0,
	0,
	0,--100
	0,
	'UNK',
	'UNK',
	'UNK',
	'UNK',
	'UNK',
	'UNK',
	0,
	0,
	0,--110
	0,
	0,
	'UNK',
	'UNK',
	'UNK',
	'UNK',
	'UNK',
	'Y',
	NULL,
	'N',--120
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,--130
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,--140
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	1,
	'TRAILER',--150
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,--160
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
    NULL,
	NULL,
	NULL,
	NULL,
	NULL,--170
	NULL,
	NULL--172
)
END

select @sTrailerID as TrailerID

GO
GRANT EXECUTE ON  [dbo].[tmail_addtrailer] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create procedure [dbo].[d_paperworktypesforrsrctype_sp] (@lgh_number int, 
						@asgntype varchar(6), @asgnid varchar(8), 
						@ord_hdrnumber integer)
as

/*
Stored Procedure d_paperworktypesforrsrctype_sp;  Paperwork (doc) types for Resource (asset) types
PTS 63723
10-4-2012 15:19 / JSWIN 
*/

Set NoCount ON 

IF @lgh_number is null OR @lgh_number  <= 0 
	select @lgh_number = 0
	
IF @ord_hdrnumber is null OR @ord_hdrnumber <= 0
	select @ord_hdrnumber = 0	

If @asgntype is null or LTrim(RTrim(@asgntype )) = '' 
	select @asgntype = ''

If @asgnid is null or LTrim(RTrim(@asgnid )) = '' 
	select @asgnid = ''

Declare @ls_AsgnType		VARCHAR(6) 
Declare @ls_TrackBranch		CHAR(1)
Declare	@ls_ProfileLogging	CHAR(1)
Declare @ls_actType			CHAR(1)
Declare @effective			DATETIME
Declare @Drv_ID				VARCHAR(13)
Declare @Drv2_ID			VARCHAR(13)
Declare @Trc_ID				VARCHAR(13)
Declare @Trl_ID				VARCHAR(13)
Declare @Car_ID				VARCHAR(13)
Declare @ll_Ord_HdrNumber	Int
declare @ls_billto			varchar(8)
declare @ls_ordnumber		varchar(12)
declare	@lgh_ord_hdrnumber	int

If		@ord_hdrnumber > 0 Set @ll_Ord_HdrNumber = @ord_hdrnumber
If		@ord_hdrnumber <=0 
		Select @ll_Ord_HdrNumber = MIN(ord_hdrnumber) from legheader where lgh_number = @lgh_number	

set		@ls_TrackBranch = ( select gi_string1 from generalinfo where gi_name = 'TrackBranch')   
If		@ls_TrackBranch <> 'Y' select @ls_TrackBranch = 'N'
set		@ls_ProfileLogging = ( select gi_string1 from generalinfo  where gi_name = 'EnableAssetProfileLogging' )
If		@ls_ProfileLogging <> 'Y' select @ls_ProfileLogging = 'N'

Declare @tmp_PayableAssets Table
( 			asset_type 		char(1) 		Null
			,asset_id     	varchar(8) 		Null 
			,asgn_type		varchar(6)		Null
			,actg_ck_type	char(1)			Null
			,aid_type1		varchar(6)		NULL
			,aid_type2		varchar(6)		NULL
            ,aid_type3		varchar(6)		NULL
            ,aid_type4		varchar(6)		NULL
			,aid_branch		varchar(12)		Null			
)

Declare @tmp_AssetDocTypes Table
(			pat_doctype		varchar(6) NULL
           ,asgn_type		varchar(6) NULL
           ,asset_type1		varchar(6) NULL
           ,asset_type2		varchar(6) NULL
           ,asset_type3		varchar(6) NULL
           ,asset_type4		varchar(6) NULL
           ,asset_branch	varchar(12) NULL  )

Declare @tmp_PprWrk Table
(			pat_doctype			varchar(6)	  NULL
			,asgn_type			varchar(6)    NULL
			,asset_type1		varchar(6)    NULL
			,asset_type2		varchar(6)    NULL
			,asset_type3		varchar(6)    NULL
			,asset_type4		varchar(6)    NULL
			,asset_branch		varchar(12)    NULL )          

Declare @paperworkcheck_dwo Table
(	LabelFile_Name			 VARCHAR(20)	NULL
  , PW_received				 CHAR(1)		NULL
  ,	PW_ord_hdrnumber		 INT			NULL
  , PW_Abbr					 VARCHAR(6)		NULL
  , LabelFile_Code			 INT			NULL
  , LabelFile_Abbr			 VARCHAR(6)		NULL 
  , PW_DT					 DATETIME		NULL
  , cc_pwrequired			 INT			NULL  
  , PW_Last_UpdatedBy		 VARCHAR(256)	NULL
  , PW_Last_UpdatedDateTime  DATETIME		NULL  
  , PW_Lgh_Number			 INT			NULL
  , OH_Ord_Number			 VARCHAR(12)	NULL    
  , cc_retrievedordhdrnumber INT			NULL
  ,	BDT_required_for_APP	 CHAR(1)		NULL
  ,	BDT_required_for_DISP	 CHAR(1)		NULL 	
  ,	CTpwC_Cmp_id			 VARCHAR(8)		NULL
  ,	CPW_cht_number			 INT			NULL	
  ,	CPW_paperwork			 VARCHAR(6)		NULL    	
  ,	CPW_sequence			 INT			NULL	
  ,	CPW_Inv_Required		 CHAR(1)		NULL	
  ,	CPW_Inv_Attach			 CHAR(1)		NULL        
)	

-------------------- * 

 DECLARE @tmp_profilelog TABLE
   ( effective       DATETIME
   , Drv_ID          VARCHAR(13)
   , DrvType1        VARCHAR(50)
   , DrvType2        VARCHAR(50)
   , DrvType3        VARCHAR(50)
   , DrvType4        VARCHAR(50)
   , DrvCompany      VARCHAR(50)
   , DrvDivision     VARCHAR(50)
   , DrvFleet        VARCHAR(50)
   , DrvTerminal     VARCHAR(50)
   , DrvTeamLeader   VARCHAR(50)
   , DrvDomicile     VARCHAR(50)
   , Trc_ID          VARCHAR(13)
   , TrcType1        VARCHAR(50)
   , TrcType2        VARCHAR(50)
   , TrcType3        VARCHAR(50)
   , TrcType4        VARCHAR(50)
   , TrcCompany      VARCHAR(50)
   , TrcDivision     VARCHAR(50)
   , TrcFleet        VARCHAR(50)
   , TrcTerminal     VARCHAR(50)
   , Trl_ID          VARCHAR(13)
   , TrlType1        VARCHAR(50)
   , TrlType2        VARCHAR(50)
   , TrlType3        VARCHAR(50)
   , TrlType4        VARCHAR(50)
   , TrlCompany      VARCHAR(50)
   , TrlDivision     VARCHAR(50)
   , TrlFleet        VARCHAR(50)
   , TrlTerminal     VARCHAR(50)
   , Car_ID          VARCHAR(13)
   , CarType1        VARCHAR(50)
   , CarType2        VARCHAR(50)
   , CarType3        VARCHAR(50)
   , CarType4        VARCHAR(50)
   )

--================  Set up base data ============
-- if we have a leg#	( grab initial data )
If @lgh_number > 0
Begin  	
	Insert into @tmp_PayableAssets (asset_type, asset_id, asgn_type, actg_ck_type, aid_branch)
	SELECT	distinct 
				CASE 
					when asgn_type =   'DRV' and asgn_controlling = 'Y' then '1'
					when asgn_type =   'DRV' and asgn_controlling = 'N' then '2'
					when asgn_type =   'TRC' then '3'
					when asgn_type =   'CAR' then '4'
					when asgn_type =   'TRL' then '5'
				End as 'asset_type', 
				
				asgn_id as 'asset_id',
				asgn_type as 'asgn_type',
					
				CASE 
					when asgn_type = 'DRV' then  ( select isnull(mpp_actg_type, 'N') 
													from manpowerprofile where mpp_id = assetassignment.asgn_id 
													and isnull(mpp_actg_type, 'N') <> 'N' )
					when asgn_type = 'TRC' then ( select isnull(trc_actg_type, 'N') 
													from tractorprofile where trc_number = assetassignment.asgn_id 
													and isnull(trc_actg_type, 'N') <> 'N' )
					when asgn_type = 'CAR' then ( select isnull(car_actg_type, 'N') from carrier where car_id =  assetassignment.asgn_id 
													and  isnull(car_actg_type, 'N')<> 'N' )
					when asgn_type = 'TRL' then ( select isnull(trl_actg_type, 'N') from trailerprofile where trl_number = assetassignment.asgn_id 
													and isnull(trl_actg_type, 'N')  <> 'N' )
				End as 	'actg_ck_type',
				
				'UNKNOWN' as 'aid_branch'
				
	FROM 		assetassignment 
	WHERE 		assetassignment.lgh_number = @lgh_number 
	AND 		ISNULL(actg_type, 'N') <> 'N'
	  
	UNION

	SELECT   		distinct 
					'7'  'asset_type',  
     	  			Thirdpartyassignment.tpr_id 'asset_id' ,
     				cast(thirdpartyprofile.tpr_type as varchar(6) ) 'asgn_type',
					thirdpartyprofile.tpr_actg_type as 	'actg_ck_type',	
					thirdpartyprofile.tpr_branch as 'aid_branch'
	FROM 			Thirdpartyassignment,   Thirdpartyprofile 
	WHERE 			Thirdpartyassignment.tpr_id = thirdpartyprofile.tpr_id  and  
					Thirdpartyassignment.lgh_number = @lgh_number   AND  
					isnull(Thirdpartyassignment.tpa_status, '') <> 'DEL'  AND
					thirdpartyprofile.tpr_active = 'Y' AND
					isnull(thirdpartyprofile.tpr_actg_type, 'N')  = 'A'  
	
	
	-- if proc called using specific type+id, limit data to only that.	
	IF @asgntype > ''  AND  @asgnid > ''
	begin
		Delete from @tmp_PayableAssets 
		where ( asset_type <> @asgntype AND asset_id <> @asgnid ) 
	end
		
End 

-- if we DO NOT have a leg#  ( grab initial data )
if @lgh_number = 0  AND ( @asgntype > ''  AND  @asgnid > '' ) 
Begin

	Set @ls_actType	= ( Select Case @asgntype
							when	'DRV' then ( select isnull(mpp_actg_type, 'N') 
													from manpowerprofile where mpp_id = @asgnid
													and isnull(mpp_actg_type, 'N') <> 'N' )									
							when	'TRC' then ( select isnull(trc_actg_type, 'N') 
													from tractorprofile where trc_number = @asgnid
													and isnull(trc_actg_type, 'N') <> 'N' )	
							when	'CAR' then ( select isnull(car_actg_type, 'N') from carrier where car_id =  @asgnid
													and  isnull(car_actg_type, 'N') <> 'N' )
							when	'TRL' then ( select isnull(trl_actg_type, 'N') from trailerprofile where trl_number = @asgnid
													and isnull(trl_actg_type, 'N')  <> 'N' )
							when    'TPR' then (select isnull(tpr_actg_type, 'N') from thirdpartyprofile
													where  tpr_id = @asgnid And tpr_active = 'Y' 					
													AND isnull(thirdpartyprofile.tpr_actg_type, 'N')  = 'A')						
						END ) 
	
	IF @ls_actType IS Null  Select @ls_actType = 'N'
	
	Insert into @tmp_PayableAssets (asset_type, asset_id, asgn_type, actg_ck_type, aid_branch)
	Select CASE @asgntype
				when	'DRV' then '1'					
				when	'TRC' then '3'
				when	'CAR' then '4'
				when	'TRL' then '5'
				when    'TPR' then '7'
			END as  'asset_type',
			@asgnid			as	'asset_id',				
			@asgntype		as	'asgn_type',
			@ls_actType		as	'actg_ck_type',
			'UNKNOWN'		as  'aid_branch'	
End

-- continue base set up	
If ( Select count(*) from @tmp_PayableAssets ) > 0
Begin

	Update @tmp_PayableAssets
		set	aid_type1 = mpp_type1,	
				aid_type2	= mpp_type2, 	
				aid_type3	= mpp_type3,	
				aid_type4	= mpp_type4,
				aid_branch  = mpp_branch				
				from @tmp_PayableAssets tpa left join manpowerprofile on tpa.asset_id = manpowerprofile.mpp_id 
				where tpa.asgn_type = 'DRV'
				
	Update @tmp_PayableAssets
		set	aid_type1 = trc_type1,	
				aid_type2	= trc_type2, 	
				aid_type3	= trc_type3,	
				aid_type4	= trc_type4,
				aid_branch  = trc_branch				
				from @tmp_PayableAssets tpa left join tractorprofile  on tpa.asset_id = tractorprofile.trc_number
				where tpa.asgn_type = 'TRC'			
				
	Update @tmp_PayableAssets
		set	aid_type1 = car_type1,	
				aid_type2	= car_type2, 	
				aid_type3	= car_type3,	
				aid_type4	= car_type4,
				aid_branch  = car_branch				
				from @tmp_PayableAssets tpa left join carrier on tpa.asset_id = carrier.car_id 
				where tpa.asgn_type = 'CAR'
				
	Update @tmp_PayableAssets
		set	aid_type1 = trl_type1,	
				aid_type2	= trl_type2, 	
				aid_type3	= trl_type3,	
				aid_type4	= trl_type4,
				aid_branch  = trl_branch				
				from @tmp_PayableAssets tpa left join trailerprofile on tpa.asset_id = trailerprofile.trl_number
				where tpa.asgn_type = 'TRL'			

	Insert into @tmp_PprWrk	
	(		pat_doctype  
           ,asgn_type  
           ,asset_type1  
           ,asset_type2  
           ,asset_type3  
           ,asset_type4  
           ,asset_branch  
     )    
	Select			paperwork_by_assettypes.pat_doctype,   
					paperwork_by_assettypes.asgn_type,   
					paperwork_by_assettypes.asset_type1,   
					paperwork_by_assettypes.asset_type2,   
					paperwork_by_assettypes.asset_type3,   
					paperwork_by_assettypes.asset_type4,
					paperwork_by_assettypes.asset_branch					
	FROM 			paperwork_by_assettypes
	Right Join  	labelfile
	ON				paperwork_by_assettypes.pat_doctype = labelfile.abbr  
	Right Join		@tmp_PayableAssets tpa on 	paperwork_by_assettypes.asgn_type = tpa.asgn_type
	WHERE			paperwork_by_assettypes.asgn_type in (select Distinct asgn_type from @tmp_PayableAssets)
	AND				labelfile.labeldefinition = 'PaperWork'
	AND				labelfile.retired <> 'Y'	  
	
			
	IF @ls_TrackBranch = 'N' 
	BEGIN
		Update @tmp_PayableAssets set aid_branch = 'UNKNOWN'
		Update @tmp_PprWrk set asset_branch = 'UNKNOWN'	
	END	
end	
-- ( end of " If @tmp_PayableAssets has rows " )


-- if the GI is not set or if we there is no leg #, skip this.
If @ls_ProfileLogging = 'Y' AND @lgh_number > 0
BEGIN
	select @effective = lgh_startdate, 
		   @Drv_ID	  = lgh_driver1,
		   @Drv2_ID	  = lgh_driver2,
		   @Trc_ID	  = lgh_tractor,			
		   @Trl_ID	  = lgh_primary_trailer,		
		   @Car_ID	  = lgh_carrier	
	from	legheader 
	where	lgh_number = @lgh_number	


	INSERT INTO @tmp_profilelog 
   ( effective    
   , Drv_ID
   , DrvType1     
   , DrvType2     
   , DrvType3     
   , DrvType4     
   , DrvCompany   
   , DrvDivision  
   , DrvFleet     
   , DrvTerminal  
   , DrvTeamLeader
   , DrvDomicile  
   , Trc_ID
   , TrcType1     
   , TrcType2     
   , TrcType3     
   , TrcType4     
   , TrcCompany   
   , TrcDivision  
   , TrcFleet     
   , TrcTerminal  
   , Trl_ID
   , TrlType1     
   , TrlType2     
   , TrlType3     
   , TrlType4     
   , TrlCompany   
   , TrlDivision  
   , TrlFleet     
   , TrlTerminal  
   , Car_ID
   , CarType1
   , CarType2
   , CarType3
   , CarType4
   )
   exec d_getResourceTypes_From_Log_sp  @effective, @Drv_ID, @Trc_ID , @Trl_ID, @Car_ID

	if @Drv2_ID <> 'UNKNOWN'
	begin
			INSERT INTO @tmp_profilelog 
		   ( effective    
		   , Drv_ID
		   , DrvType1     
		   , DrvType2     
		   , DrvType3     
		   , DrvType4     
		   , DrvCompany   
		   , DrvDivision  
		   , DrvFleet     
		   , DrvTerminal  
		   , DrvTeamLeader
		   , DrvDomicile  
		   , Trc_ID
		   , TrcType1     
		   , TrcType2     
		   , TrcType3     
		   , TrcType4     
		   , TrcCompany   
		   , TrcDivision  
		   , TrcFleet     
		   , TrcTerminal  
		   , Trl_ID
		   , TrlType1     
		   , TrlType2     
		   , TrlType3     
		   , TrlType4     
		   , TrlCompany   
		   , TrlDivision  
		   , TrlFleet     
		   , TrlTerminal  
		   , Car_ID
		   , CarType1
		   , CarType2
		   , CarType3
		   , CarType4
		   )
		   exec d_getResourceTypes_From_Log_sp  @effective, @Drv2_ID, '','',''
	end
END
--  end of ( IF GI for ProfileLogging = Y )

--================  Set up paperwork Doc types ( based on types of Assets on trip ) ============		
If ( Select count(*) from @tmp_PayableAssets ) > 0
Begin
--	begin (if count>0) condition
	
	If ( Select count(*) from @tmp_PayableAssets where asgn_type = 'DRV' ) > 0
	Begin
		--	begin (if Driver) condition		
		set @ls_AsgnType = 'DRV'
			
		Insert Into @tmp_AssetDocTypes
		(	pat_doctype  
           ,asgn_type  
           ,asset_type1  
           ,asset_type2  
           ,asset_type3  
           ,asset_type4  
           ,asset_branch     
		) 
		SELECT 			paperwork_by_assettypes.pat_doctype,   
						paperwork_by_assettypes.asgn_type,   
						paperwork_by_assettypes.asset_type1,   
						paperwork_by_assettypes.asset_type2,   
						paperwork_by_assettypes.asset_type3,   
						paperwork_by_assettypes.asset_type4,						
						paperwork_by_assettypes.asset_branch										
		FROM 			paperwork_by_assettypes
		Right Join  	labelfile
		ON				paperwork_by_assettypes.pat_doctype = labelfile.abbr  
		Right Join		@tmp_PayableAssets tpa 
		ON				tpa.asgn_type = @ls_AsgnType
		Right Join		manpowerprofile
		ON				manpowerprofile.mpp_id = tpa.asset_id		
		WHERE			paperwork_by_assettypes.asgn_type = @ls_AsgnType
		AND				labelfile.labeldefinition = 'PaperWork'
		AND				labelfile.retired <> 'Y'	
		And			(	( IsNull(asset_type1, 'UNK') ='UNK' or asset_type1 = mpp_type1 ) 
		And				( IsNull(asset_type2, 'UNK') ='UNK' or asset_type2 = mpp_type2 ) 
		And				( IsNull(asset_type3, 'UNK') ='UNK' or asset_type3 = mpp_type3 ) 
		And				( IsNull(asset_type4, 'UNK') ='UNK' or asset_type4 = mpp_type4 ) ) 
		And				( ISNULL(paperwork_by_assettypes.asset_branch, 'UNKNOWN') = 'UNKNOWN' OR  paperwork_by_assettypes.asset_branch = mpp_branch ) 			
	End 
	--	end (if Driver) condition

	If ( Select count(*) from @tmp_PayableAssets where asgn_type = 'TRC' ) > 0
	Begin
		--	begin (if Tractor) condition	
		
		set @ls_AsgnType = 'TRC'
			
		Insert Into @tmp_AssetDocTypes
		(	pat_doctype  
           ,asgn_type  
           ,asset_type1  
           ,asset_type2  
           ,asset_type3  
           ,asset_type4  
           ,asset_branch       
		) 
		SELECT 			paperwork_by_assettypes.pat_doctype,   
						paperwork_by_assettypes.asgn_type,   
						paperwork_by_assettypes.asset_type1,   
						paperwork_by_assettypes.asset_type2,   
						paperwork_by_assettypes.asset_type3,   
						paperwork_by_assettypes.asset_type4,  
						paperwork_by_assettypes.asset_branch	
		FROM 			paperwork_by_assettypes
		Right Join  	labelfile
		ON				paperwork_by_assettypes.pat_doctype = labelfile.abbr 
		Right Join		@tmp_PayableAssets tpa 
		ON				tpa.asgn_type = @ls_AsgnType
		Right Join		tractorprofile
		ON				tractorprofile.trc_number = tpa.asset_id				
		WHERE			paperwork_by_assettypes.asgn_type = @ls_AsgnType
		AND				labelfile.labeldefinition = 'PaperWork'
		AND				labelfile.retired <> 'Y'
		And			(	( IsNull(asset_type1, 'UNK') ='UNK' or asset_type1 = trc_type1 ) 
		And				( IsNull(asset_type2, 'UNK') ='UNK' or asset_type2 = trc_type2 ) 
		And				( IsNull(asset_type3, 'UNK') ='UNK' or asset_type3 = trc_type3 ) 
		And				( IsNull(asset_type4, 'UNK') ='UNK' or asset_type4 = trc_type4 ) ) 	
		And				( ISNULL(paperwork_by_assettypes.asset_branch, 'UNKNOWN') = 'UNKNOWN' OR  paperwork_by_assettypes.asset_branch = trc_branch ) 
					       
	End 		
	--	end (if Tractor) condition	
		
	If ( Select count(*) from @tmp_PayableAssets where asgn_type = 'CAR' ) > 0	
	Begin
		set @ls_AsgnType = 'CAR'
			
		Insert Into @tmp_AssetDocTypes
		(	pat_doctype  
           ,asgn_type  
           ,asset_type1  
           ,asset_type2  
           ,asset_type3  
           ,asset_type4  
           ,asset_branch  
		) 
		SELECT 			paperwork_by_assettypes.pat_doctype,   
						paperwork_by_assettypes.asgn_type,   
						paperwork_by_assettypes.asset_type1,   
						paperwork_by_assettypes.asset_type2,   
						paperwork_by_assettypes.asset_type3,   
						paperwork_by_assettypes.asset_type4,  
						paperwork_by_assettypes.asset_branch
		FROM 			paperwork_by_assettypes
		Right Join  	labelfile
		ON				paperwork_by_assettypes.pat_doctype = labelfile.abbr  
		Right Join		@tmp_PayableAssets tpa 
		ON				tpa.asgn_type = @ls_AsgnType
		Right Join		carrier
		ON				carrier.car_id = tpa.asset_id	
		WHERE			paperwork_by_assettypes.asgn_type = @ls_AsgnType
		AND				labelfile.labeldefinition = 'PaperWork'
		AND				labelfile.retired <> 'Y'
		And			(	( IsNull(asset_type1, 'UNK') ='UNK' or asset_type1 = car_type1 ) 
		And				( IsNull(asset_type2, 'UNK') ='UNK' or asset_type2 = car_type2 ) 
		And				( IsNull(asset_type3, 'UNK') ='UNK' or asset_type3 = car_type3 ) 
		And				( IsNull(asset_type4, 'UNK') ='UNK' or asset_type4 = car_type4 ) ) 	
		And				( ISNULL(paperwork_by_assettypes.asset_branch, 'UNKNOWN') = 'UNKNOWN' OR  paperwork_by_assettypes.asset_branch = car_branch ) 
	End    
	--	end (if carrier) condition		
		
	If ( Select count(*) from @tmp_PayableAssets where asgn_type = 'TRL' ) > 0	
	Begin		
		set @ls_AsgnType = 'TRL'
			
		Insert Into @tmp_AssetDocTypes
		(	pat_doctype  
           ,asgn_type  
           ,asset_type1  
           ,asset_type2  
           ,asset_type3  
           ,asset_type4  
           ,asset_branch  
		) 
		SELECT 			paperwork_by_assettypes.pat_doctype,   
						paperwork_by_assettypes.asgn_type,   
						paperwork_by_assettypes.asset_type1,   
						paperwork_by_assettypes.asset_type2,   
						paperwork_by_assettypes.asset_type3,   
						paperwork_by_assettypes.asset_type4,  
						paperwork_by_assettypes.asset_branch
		FROM 			paperwork_by_assettypes
		Right Join  	labelfile
		ON				paperwork_by_assettypes.pat_doctype = labelfile.abbr  
		Right Join		@tmp_PayableAssets tpa 
		ON				tpa.asgn_type = @ls_AsgnType
		Right Join		trailerprofile
		ON				trailerprofile.trl_number = tpa.asset_id	
		WHERE			paperwork_by_assettypes.asgn_type = @ls_AsgnType
		AND				labelfile.labeldefinition = 'PaperWork'
		AND				labelfile.retired <> 'Y'
		And			(	( IsNull(asset_type1, 'UNK') ='UNK' or asset_type1 = trl_type1 ) 
		And				( IsNull(asset_type2, 'UNK') ='UNK' or asset_type2 = trl_type2 ) 
		And				( IsNull(asset_type3, 'UNK') ='UNK' or asset_type3 = trl_type3 ) 
		And				( IsNull(asset_type4, 'UNK') ='UNK' or asset_type4 = trl_type4 ) ) 	
		And				( ISNULL(paperwork_by_assettypes.asset_branch, 'UNKNOWN') = 'UNKNOWN' OR  paperwork_by_assettypes.asset_branch = trl_branch ) 
	End  
	--	end (if trailer) condition		
		
	If ( Select count(*) from @tmp_PayableAssets where asgn_type = 'TPR' ) > 0	Begin
	--	begin (if thirdparty ) condition		
		set @ls_AsgnType = 'TPR'
			
		Insert Into @tmp_AssetDocTypes
		(	pat_doctype  
           ,asgn_type  
           ,asset_type1  
           ,asset_type2  
           ,asset_type3  
           ,asset_type4  
           ,asset_branch  
		) 
		SELECT 			paperwork_by_assettypes.pat_doctype,   
						paperwork_by_assettypes.asgn_type,   
						paperwork_by_assettypes.asset_type1,   
						paperwork_by_assettypes.asset_type2,   
						paperwork_by_assettypes.asset_type3,   
						paperwork_by_assettypes.asset_type4,  
						paperwork_by_assettypes.asset_branch									
		FROM 			paperwork_by_assettypes
		Right Join  	labelfile
		ON				paperwork_by_assettypes.pat_doctype = labelfile.abbr  
		Right Join		@tmp_PayableAssets tpa 
		ON				tpa.asgn_type = @ls_AsgnType
		Right Join		thirdpartyprofile
		ON				thirdpartyprofile.tpr_id = tpa.asset_id	
		WHERE			paperwork_by_assettypes.asgn_type = @ls_AsgnType
		AND				labelfile.labeldefinition = 'PaperWork'
		AND				labelfile.retired <> 'Y'
		And			(	( IsNull(asset_type1, 'UNK') ='UNK' or asset_type1 =  tpr_revtype1 ) 
		And				( IsNull(asset_type2, 'UNK') ='UNK' or asset_type2 =  tpr_revtype2 ) 
		And				( IsNull(asset_type3, 'UNK') ='UNK' or asset_type3 =  tpr_revtype3 ) 
		And				( IsNull(asset_type4, 'UNK') ='UNK' or asset_type4 =  tpr_revtype4 ) ) 	
		And				( ISNULL(paperwork_by_assettypes.asset_branch, 'UNKNOWN') = 'UNKNOWN' OR  paperwork_by_assettypes.asset_branch = tpr_branch ) 
	End 
		--	end (if thirdparty) condition
END	-- end the if count >0 condition...	

--==================================================
--================ PrePare dwo ResultSet ===========
--==================================================	
set @lgh_ord_hdrnumber = ( select ord_hdrnumber from legheader where lgh_number =  @lgh_number )
if  @ord_hdrnumber > 0     select @ls_ordnumber = ord_number, @ls_billto = ord_billto  from orderheader where ord_hdrnumber = @ord_hdrnumber

if ( @ord_hdrnumber <= 0 and @lgh_number > 0 ) 
	select @ls_ordnumber = ord_number, @ls_billto = ord_billto, @ord_hdrnumber = @lgh_ord_hdrnumber  
	from orderheader 
	where ord_hdrnumber = @lgh_ord_hdrnumber

if	@ls_billto is null set @ls_billto = ''

insert into @paperworkcheck_dwo ( PW_Lgh_Number, OH_Ord_Number,  PW_ord_hdrnumber,
								 LabelFile_Name, LabelFile_Code, LabelFile_Abbr,  
								 PW_Abbr,								
								 cc_pwrequired, cc_retrievedordhdrnumber	)
								 
			select	@lgh_number, @ls_ordnumber, 	@lgh_ord_hdrnumber,
					labelfile.name, labelfile.code, labelfile.abbr,
					adt.pat_doctype, 					
					0,  -- cc_pwrequired 
					0  --cc_retrievedordhdrnumber  ?? don't know what this is
			from	@tmp_AssetDocTypes adt
			right join labelfile on adt.pat_doctype = labelfile.abbr 
			where	labelfile.abbr in (Select Distinct(pat_doctype) from @tmp_AssetDocTypes)	
			and		labelfile.labeldefinition = 'PaperWork' 

update @paperworkcheck_dwo 
		 SET BDT_required_for_APP = BillDoctypes.bdt_required_for_application,
			 BDT_required_for_DISP = BillDoctypes.bdt_required_for_dispatch
		 from @paperworkcheck_dwo pdwo	 
		 right join BillDoctypes on BillDoctypes.bdt_doctype = pdwo.PW_Abbr	 
		 where BillDoctypes.cmp_id = @ls_billto		
		 and   ( pdwo.BDT_required_for_APP is null  and   pdwo.BDT_required_for_DISP is null )
	
update	@paperworkcheck_dwo 	
		Set pw_dt = paperwork.pw_dt, 
			pw_last_updatedby = paperwork.last_updatedby, 
			pw_last_updateddatetime = paperwork.last_updateddatetime 
			from  paperwork, @paperworkcheck_dwo pdwo where paperwork.abbr = pdwo.PW_Abbr
			and paperwork.ord_hdrnumber = @ll_Ord_HdrNumber 
			
 --================ Return Dwo Final ResultSet ===========
 select	 LabelFile_Name					as 'name'
		,IsNull(PW_received, 'N')		as 'pw_received'
		,PW_ord_hdrnumber				as 'ord_hdrnumber'
		,PW_Abbr						as 'abbr'
		,LabelFile_Code					as 'code' 
		,LabelFile_Abbr					as 'abbr'  
		,IsNull(PW_DT, GETDATE())		as 'pw_dt'
		,1								as 'Required'
		,suser_sname()					as 'last_updatedby' 
		,GETDATE()						as 'last_updateddatetime'  
		,PW_Lgh_Number					as 'lgh_number'
		,OH_Ord_Number					as 'ord_number'  
		,@ll_Ord_HdrNumber				as 'ord_hdrnumber'
		,'R'							as 'app'
		,IsNull(BDT_required_for_DISP, 'N')			as 'bdt_required_for_dispatch' 
from	@paperworkcheck_dwo  
 
 
RETURN
GO
GRANT EXECUTE ON  [dbo].[d_paperworktypesforrsrctype_sp] TO [public]
GO

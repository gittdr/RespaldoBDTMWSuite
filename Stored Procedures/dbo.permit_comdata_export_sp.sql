SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- CHANGE LOG
-- PTS 47339 SGB 05/01/09 Added overhng to overall length calculation
-- PTS 52850 SGB 08/18/10 Corrected Company Information and Serial Number for Consolidated Trips

create procedure [dbo].[permit_comdata_export_sp] @P_ID int, @lgh_number int, @mov_number int, @ord_hdrnumber int
 
as


DECLARE @RecordTerminator char(1)
DECLARE @TotalAxleSpacing int
DECLARE @TotalAxleCount int
DECLARE @TrailerAxleOffset int
DECLARE @LogNum int
DECLARE @LogNumOut char(5)
DECLARE @WeightSum int
DECLARE @TotalScaledWeight int
DECLARE @OverallLength int
DECLARE @P_Transmit_To_Type varchar(6)
DECLARE @P_Transmit_To varchar(13)
DECLARE @P_Transmit_Method varchar(6)
DECLARE @FaxToName varchar(75)
DECLARE @FaxToCityStateZip varchar(75)
DECLARE @FaxNumber varchar(10)
DECLARE @FaxAreaCode varchar(3)
DECLARE @FaxPrefixNumber varchar(7)
DECLARE @LFT char(2)
DECLARE @LIN char(2)
DECLARE @WFT char(2)
DECLARE @WIN char(2)
DECLARE @HFT char(2)
DECLARE @HIN char(2)
DECLARE @AxleWeight int
DECLARE @CurrentAxle smallint
DECLARE @recordptr_route int
DECLARE @recordcount_route int
DECLARE @routeseparator varchar(1)
DECLARE @routedetail_line varchar(72)
DECLARE @routedetail_Route varchar(50)
DECLARE @routedetail_Direction varchar(15)
DECLARE @routedetail_ToIntersection varchar(15)
DECLARE @route_name varchar(50)
DECLARE @OrderCount int
--Returns a resultset that can be written to a file for COMDATA permits 
--This is to be one byte longer than the actual maximum output record size to hold a record terminator.
--Otherwise spaces are truncated
Create table #foroutput(
	recbuf varchar(592) 
)

--Permit header PMTHDR
create table #PermitHeader(
	LOGNUM		char(5)		NULL,	--Log Number
	RCDCD		char(2)		NULL,	--Record Code (01)
	LINENUM		char(2)		NULL,	--Line Number (00)
	CMNAME		char(30)	NULL,	--Company Name
	ACCTNO		char(6)		NULL,	--Account Number
	TRIPNO		char(7)		NULL,	--Trip Number
	PERMITDATE	char(6)		NULL, 	--Date-MMDDYY
	PERMITTIME	char(6)		NULL, 	--Time-HHMMSS
	DRNAME		char(25)	NULL,	--Driver Name
	LDDESC		char(20)	NULL,	--Load Description
	UNIT		char(6)		NULL, 	--Tractor
	LSNBR		char(10)	NULL, 	--Load Serial Number
	TRLR		char(6)		NULL, 	--Trailer
	EQ1		char(6)		NULL, 	--Misc Equip 1
	EQ2		char(6)		NULL, 	--Misc Equip 2
	EQ3		char(6)		NULL, 	--Misc Equip 3
	EQ4		char(6)		NULL, 	--Misc Equip 4
	EQ5		char(6)		NULL, 	--Misc Equip 5
	EQ6		char(6)		NULL, 	--Misc Equip 6
	ONAME		char(25)	NULL,	--Origin Name
	OL1		char(25)	NULL,	--Origin Line 1
	OL2		char(25)	NULL,	--Origin Line 2
	OL3		char(25)	NULL,	--Origin Line 3
	DNAME		char(25)	NULL,	--Destination Name
	DL1		char(25)	NULL,	--Destination Line 1
	DL2		char(25)	NULL,	--Destination Line 2
	DL3		char(25)	NULL,	--Destination Line 3
	UYR		char(2)		NULL, 	--Tractor Year
	UMAK		char(12)	NULL,	--Tractor Make
	ULIC		char(8)		NULL,	--Tractor License Number
	USNBR		char(19)	NULL,	--Tractor Serial Number
	UWGT		char(5)		NULL,	--Tractor Weight
	TYR		char(2)		NULL,	--Trailer Year
	TMAK		char(12)	NULL,	--Trailer Make
	TLIC		char(8)		NULL,	--Trailer License
	TSNBR		char(19)	NULL,	--Trailer Serial Number
	TWGT		char(5)		NULL,	--Trailer Weight
	UFT1		char(2)		NULL,	--Tractor Axle Spacing 1-FT
	UIN1		char(2)		NULL,	--Tractor Axle Spacing 1-IN
	UFT2		char(2)		NULL,	--Tractor Axle Spacing 2-FT
	UIN2		char(2)		NULL,	--Tractor Axle Spacing 2-IN
	UFT3		char(2)		NULL,	--Tractor Axle Spacing 3-FT
	UIN3		char(2)		NULL,	--Tractor Axle Spacing 3-IN
	UFT4		char(2)		NULL,	--Tractor Axle Spacing 4-FT
	UIN4		char(2)		NULL,	--Tractor Axle Spacing 4-IN
	TFT1		char(2)		NULL,	--Trailer Axle Spacing 1-FT
	TIN1		char(2)		NULL,	--Trailer Axle Spacing 1-IN
	TFT2		char(2)		NULL,	--Trailer Axle Spacing 2-FT
	TIN2		char(2)		NULL,	--Trailer Axle Spacing 2-IN
	TFT3		char(2)		NULL,	--Trailer Axle Spacing 3-FT
	TIN3		char(2)		NULL,	--Trailer Axle Spacing 3-IN
	TFT4		char(2)		NULL,	--Trailer Axle Spacing 4-FT
	TIN4		char(2)		NULL,	--Trailer Axle Spacing 4-IN
	TFT		char(3)		NULL,	--Total Axle Spacing 4-FT
	TIN		char(2)		NULL,	--Total Axle Spacing 4-IN
	UTSZ		char(10)	NULL,	--Tractor Tire Size
	TTSZ		char(10)	NULL,	--Trailer Tire Size
	PGRWT		char(7)		NULL,	--Permitted Gross Weight
	PTWGT		char(7)		NULL,	--Permitted Total Gross Weight
	TWGTS		char(6)		NULL,	--Total Weight
	TAXLE		char(2)		NULL,	--Axles
	PSCSR		char(5)		NULL,	--Scaled Weights Stering
	PSCDR		char(5)		NULL,	--Scaled Weights Driver
	PSCJP		char(5)		NULL,	--Scaled Weights Jeep
	PSCTL		char(5)		NULL,	--Scaled Weights Trailer
	PSCST		char(5)		NULL,	--Scaled Weights Stringer
	LFT		char(3)		NULL,	--Load Dimensions Length FT
	LIN		char(2)		NULL,	--Load Dimensions Length IN
	WFT		char(2)		NULL,	--Load Dimensions Width FT
	WIN		char(2)		NULL,	--Load Dimensions Width IN
	HFT		char(2)		NULL,	--Load Dimensions Height FT
	HIN		char(2)		NULL,	--Load Dimensions Height IN
	OLFT		char(3)		NULL,	--Overall Dimensions Length FT
	OLIN		char(2)		NULL,	--Overall Dimensions Length IN
	OWFT		char(2)		NULL,	--Overall Dimensions Width FT
	OWIN		char(2)		NULL,	--Overall Dimensions Width IN
	OHFT		char(2)		NULL,	--Overall Dimensions Height FT
	OHIN		char(2)		NULL	--Overall Dimensions Height IN
)

--PMTODR
create table #PermitOrderInfo(
	LOGNUM		char(5)		NULL,	--Log Number
	RCDCD		char(2)		NULL,	--Record Code (04)
	LINENUM		char(2)		NULL,	--Line Number (01-nn)
	STATE		char(2)		NULL,	--State
	ROUTE		char(72)	NULL,	--Route Information
	RDATE		char(6)		NULL,	--Requested Date (MMDDYY)
	ATTN		char(30)	NULL,	--Sent to Attention
	PFAC		char(3)		NULL,	--Sent to Fax Area Code
	PFNBR		char(7)		NULL,	--Sent to Fax Phone Number
	UDATE		char(6)		NULL,	--Todays date (MMDDYY)
	EXDT		char(6)		NULL,	--Expiration Date (MMDDYY)
	TOTW		char(6)		NULL,	--Total Weight
	AX1		char(2)		NULL,	--Axle Weight 1
	AX2		char(2)		NULL,	--Axle Weight 2
	AX3		char(2)		NULL,	--Axle Weight 3
	AX4		char(2)		NULL,	--Axle Weight 4
	AX5		char(2)		NULL,	--Axle Weight 5
	INTLS		char(3)		NULL,	--Initials
	PTYPE		char(5)		NULL	--Permit Type
)	

--PMTCMT
create table #PermitComments(
	LOGNUM		char(5)		NULL,	--Log Number
	RCDCD		char(2)		NULL,	--Record Code (05)
	LINENUM		char(2)		NULL,	--Line Number (00)
	CMT1		char(75)	NULL,	--Comment Line 1
	CMT2		char(75)	NULL,	--Comment Line 2
	CMT3		char(75)	NULL,	--Comment Line 3
	NPERM		char(4)		NULL,	--Number of permits required
	FDLOG		char(5)		NULL	--Log Number	
)

--PMTSTA
create table #PermitRequiredStates(
	LOGNUM		char(5)		NULL,	--Log Number
	RCDCD		char(2)		NULL,	--Record Code (06)
	LINENUM		char(2)		NULL,	--Line Number (00)
	ST01		char(2)		NULL,	--State 1	
	ST02		char(2)		NULL,	--State 2	
	ST03		char(2)		NULL,	--State 3	
	ST04		char(2)		NULL,	--State 4	
	ST05		char(2)		NULL,	--State 5	
	ST06		char(2)		NULL,	--State 6	
	ST07		char(2)		NULL,	--State 7	
	ST08		char(2)		NULL	--State 8	
)

SELECT @RecordTerminator = '~'


--Define Comdata export fields for all records

--Get next log number.
--Note that max is 5 digits

EXECUTE @LogNum = getsystemnumber 'PERMCDEX', '' 
SET @LogNumOut = right('00000' + CAST(@LogNum % 100000 as varchar(5)), 5)


INSERT INTO #PermitHeader(
	LOGNUM,
	RCDCD,
	LINENUM,
	CMNAME,
	ACCTNO,
	TRIPNO,
	PERMITDATE,
	PERMITTIME,
	DRNAME,
	LDDESC,
	UNIT,
	LSNBR,
	TRLR,
	EQ1,
	EQ2,
	EQ3,
	EQ4,
	EQ5,
	EQ6,
	ONAME,
	OL1,
	OL2,
	OL3,
	DNAME,
	DL1,
	DL2,
	DL3,
	UYR,
	UMAK,
	ULIC,
	USNBR,
	UWGT,
	TYR,
	TMAK,
	TLIC,
	TSNBR,
	TWGT,
	UFT1,
	UIN1,
	UFT2,
	UIN2,
	UFT3,
	UIN3,
	UFT4,
	UIN4,
	TFT1,
	TIN1,
	TFT2,
	TIN2,
	TFT3,
	TIN3,
	TFT4,
	TIN4,
	TFT,
	TIN,
	UTSZ,
	TTSZ,
	PGRWT,
	PTWGT,
	TWGTS,
	TAXLE,
	PSCSR,
	PSCDR,
	PSCJP,
	PSCTL,
	PSCST,
	LFT,
	LIN,
	WFT,
	WIN,
	HFT,
	HIN,
	OLFT,
	OLIN,
	OWFT,
	OWIN,
	OHFT,
	OHIN)
SELECT	@LogNumOut AS LOGNUM, 
		'01' AS RCDCD, 
		'00' AS LINENUM, 
		'' AS CMNAME, 
		'' AS ACCTNO, 
		LEFT(CAST((select orderheader.ord_number from orderheader where orderheader.ord_hdrnumber = @ord_hdrnumber) as varchar(7)), 7) AS TRIPNO,
		--RIGHT('0000000' + CAST(lgh.lgh_number as varchar(7)), 7) AS TRIPNO, 
		RIGHT(CONVERT(char(6), GETDATE(), 12), 4) + LEFT(CONVERT(char(6), GETDATE(), 12), 2) AS PERMITDATE, 
		RIGHT('0' + DATENAME(hh , GETDATE()), 2) + RIGHT('0' + DATENAME(mi , GETDATE()), 2) + RIGHT('0' + DATENAME(ss , GETDATE()), 2) AS PERMITTIME,
		LEFT(mpp.mpp_firstname + ' ' + mpp.mpp_lastname, 25) AS DRNAME, 
		LEFT(lgh.fgt_description, 20) AS LDDESC, 
		LEFT(trc.trc_number, 6) AS UNIT, 
		'' AS LSNBR, 
		LEFT(trl.trl_number, 6) AS TRLR, 
		'' AS EQ1, 
	        '' AS EQ2, 
	        '' AS EQ3, 
	        '' AS EQ4, 
	        '' AS EQ5, 
	        '' AS EQ6, 
	        '' AS ONAME, 
	        '' AS OL1, 
	        '' AS OL2, 
	        '' AS OL3, 
		'' AS DNAME, 
		'' AS DL1, 
		'' AS DL2, 
		'' AS DL3, 
		RIGHT(trc.trc_year, 2) AS UYR, 
		trc.trc_make AS UMAK, 
		trc.trc_licnum AS ULIC, 
		trc.trc_serial AS USNBR, 
		trc_tareweight AS UWGT, 
		RIGHT(trl.trl_year, 2) AS TYR, 
		trl.trl_make AS TMAK, 
		LEFT(trl.trl_licnum, 8) AS TLIC, 
		trl.trl_serial AS TSNBR, 
		trl_tareweight AS TWGT, 
		'' AS UFT1, 
		'' AS UIN1, 
		'' AS UFT2, 
		'' AS UIN2, 
		'' AS UFT3, 
		'' AS UIN3, 
		'' AS UFT4, 
		'' AS UIN4, 
		'' AS TFT1, 
		'' AS TIN1, 
		'' AS TFT2, 
		'' AS TIN2, 
		'' AS TFT3, 
		'' AS TIN3, 
		'' AS TFT4, 
		'' AS TIN4, 
		'' AS TFT, 
		'' AS TIN, 
		'' AS UTSZ, 
		'' AS TTSZ, 
		PGRWT = lgh.lgh_tot_weight,
		PTWGT = trc_tareweight + trl_tareweight + lgh.lgh_tot_weight, 
		TWGTS = trc_tareweight + trl_tareweight + lgh.lgh_tot_weight, 
		'' AS TAXLE, 
		'' AS PSCSR, 
		'' AS PSCDR, 
		'' AS PSCJP, 
		'' AS PSCTL, 
		'' AS PSCST, 
		'' AS LFT, 
		'' AS LIN, 
		'' AS WFT, 
		'' AS WIN, 
		'' AS HFT, 
		'' AS HIN, 
		'' AS OLFT, 
		'' AS OLIN, 
		CAST(ROUND(P.p_ordered_width, 0) AS int) / 12 AS OWFT, 
		CAST(ROUND(P.p_ordered_width, 0) AS int) % 12 AS OWIN, 
		CAST(ROUND(P.p_ordered_height, 0) AS int) / 12 AS OHFT,
		CAST(ROUND(P.p_ordered_height, 0) AS int) % 12 AS OHIN 
FROM	Permits AS P INNER JOIN
		legheader AS lgh ON P.lgh_number = lgh.lgh_number LEFT OUTER JOIN
                stops as s on lgh.lgh_number = s.lgh_number Left Outer Join
                event as e on s.stp_number = e.stp_number and evt_sequence = 1 Left Outer Join
		Permit_Route AS PRT ON P.PRT_ID = PRT.PRT_ID LEFT OUTER JOIN
		trailerprofile AS trl ON evt_trailer1 = trl.trl_number LEFT OUTER JOIN
		tractorprofile AS trc ON lgh.lgh_tractor = trc.trc_number LEFT OUTER JOIN
		manpowerprofile AS mpp ON lgh.lgh_driver1 = mpp.mpp_id
WHERE	(P.P_ID = @P_ID)
  	and stp_mfh_sequence = (select min(stp_mfh_sequence) 
  	                        from stops 
  	                        where (stp_type = 'PUP' or stp_type = 'DRP' or stp_event = 'XDU' or stp_event = 'XDL') 
  	                        and stops.lgh_number = lgh.lgh_number)

/*
SELECT 'DIAGNOSTIC:',P.P_ID, trc.trc_number AS UNIT, trl.trl_number AS TRLR, mpp.mpp_id , LGH.lgh_number, lgh.ord_hdrnumber
FROM	Permits AS P INNER JOIN
		legheader AS lgh ON P.lgh_number = lgh.lgh_number LEFT OUTER JOIN
		Permit_Route AS PRT ON P.PRT_ID = PRT.PRT_ID LEFT OUTER JOIN
		trailerprofile AS trl ON lgh.lgh_primary_trailer = trl.trl_number LEFT OUTER JOIN
		tractorprofile AS trc ON lgh.lgh_tractor = trc.trc_number LEFT OUTER JOIN
		manpowerprofile AS mpp ON lgh.lgh_driver1 = mpp.mpp_id
WHERE	(P.P_ID = @P_ID)
*/
-- PTS 52850 SGB See if there are consolidated Consolidated 
SELECT @OrderCount = count(distinct(ord_hdrnumber)) 
FROM stops 
WHERE mov_number = @mov_number
AND ord_hdrnumber <> 0

UPDATE	#PermitHeader
SET CMNAME = LEFT(gi_string1, 30)
FROM generalinfo
WHERE gi_name = 'PermitExportCompanyName'

--Set axle config 
UPDATE	#PermitHeader
SET		UTSZ = PAC.PAC_TireSize
FROM         Permits AS P INNER JOIN
                      Permit_Axle_Configuration AS PAC ON P.P_ID = PAC.P_ID 
WHERE     (P.P_ID = @P_ID) AND (PAC.asgn_type = 'TRC') AND (PAC.PAC_AxleNumber = 1)	

UPDATE	#PermitHeader
SET		UFT1 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) / 12,
		UIN1 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) % 12
FROM         Permits AS P INNER JOIN
                      Permit_Axle_Configuration AS PAC ON P.P_ID = PAC.P_ID 
WHERE     (P.P_ID = @P_ID) AND (PAC.asgn_type = 'TRC') AND (PAC.PAC_AxleNumber = 2)	

UPDATE	#PermitHeader
SET		UFT2 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) / 12,
		UIN2 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) % 12
FROM         Permits AS P INNER JOIN
                      Permit_Axle_Configuration AS PAC ON P.P_ID = PAC.P_ID 
WHERE     (P.P_ID = @P_ID) AND (PAC.asgn_type = 'TRC') AND (PAC.PAC_AxleNumber = 3)	

UPDATE	#PermitHeader
SET		UFT3 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) / 12,
		UIN3 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) % 12
FROM         Permits AS P INNER JOIN
                      Permit_Axle_Configuration AS PAC ON P.P_ID = PAC.P_ID 
WHERE     (P.P_ID = @P_ID) AND (PAC.asgn_type = 'TRC') AND (PAC.PAC_AxleNumber = 4)	

UPDATE	#PermitHeader
SET		UFT4 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) / 12,
		UIN4 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) % 12
FROM         Permits AS P INNER JOIN
                      Permit_Axle_Configuration AS PAC ON P.P_ID = PAC.P_ID 
WHERE     (P.P_ID = @P_ID) AND (PAC.asgn_type = 'TRC') AND (PAC.PAC_AxleNumber = 5)	

--Find the lowest axle number for the trailer
SELECT @TrailerAxleOffset = MIN(PAC_AxleNumber) - 1
FROM 	Permit_Axle_Configuration
WHERE   P_ID = @P_ID AND (asgn_type = 'TRL')

UPDATE	#PermitHeader
SET		TFT1 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) / 12,
		TIN1 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) % 12,
		TTSZ = PAC.PAC_TireSize
FROM         Permits AS P INNER JOIN
                      Permit_Axle_Configuration AS PAC ON P.P_ID = PAC.P_ID 
WHERE     (P.P_ID = @P_ID) AND (PAC.asgn_type = 'TRL') AND (PAC.PAC_AxleNumber = @TrailerAxleOffset + 1)	

UPDATE	#PermitHeader
SET		TFT2 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) / 12,
		TIN2 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) % 12
FROM         Permits AS P INNER JOIN
                      Permit_Axle_Configuration AS PAC ON P.P_ID = PAC.P_ID 
WHERE     (P.P_ID = @P_ID) AND (PAC.asgn_type = 'TRL') AND (PAC.PAC_AxleNumber = @TrailerAxleOffset + 2)	

UPDATE	#PermitHeader
SET		TFT3 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) / 12,
		TIN3 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) % 12
FROM         Permits AS P INNER JOIN
                      Permit_Axle_Configuration AS PAC ON P.P_ID = PAC.P_ID 
WHERE     (P.P_ID = @P_ID) AND (PAC.asgn_type = 'TRL') AND (PAC.PAC_AxleNumber = @TrailerAxleOffset + 3)	

UPDATE	#PermitHeader
SET		TFT4 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) / 12,
		TIN4 = CAST(ROUND(PAC_PreviousDistance, 0) AS int) % 12
FROM         Permits AS P INNER JOIN
                      Permit_Axle_Configuration AS PAC ON P.P_ID = PAC.P_ID 
WHERE     (P.P_ID = @P_ID) AND (PAC.asgn_type = 'TRL') AND (PAC.PAC_AxleNumber = @TrailerAxleOffset + 4)	

--Aggregates of all Permit_Axle_Config Records
SELECT @TotalAxleSpacing = sum(isnull(PAC_PreviousDistance, 0))
FROM	Permit_Axle_Configuration AS PAC 
WHERE	(PAC.P_ID = @P_ID) AND (PAC.PAC_AxleNumber > 1)


SELECT 	@TotalAxleCount = count(*)
FROM	Permit_Axle_Configuration AS PAC 
WHERE	(PAC.P_ID = @P_ID) 

UPDATE	#PermitHeader
SET TFT = CAST(ROUND(@TotalAxleSpacing, 0) AS int) / 12,
	TIN = CAST(ROUND(@TotalAxleSpacing, 0) AS int) % 12,
	TAXLE = @TotalAxleCount

SELECT   @WeightSum = SUM(PAC_ScaledWeight) 
FROM        Permit_Axle_Configuration
WHERE    (P_ID = @P_ID) AND (PAC_ScaledWeightType = 'STEER')

SET @TotalScaledWeight = 0
SET @TotalScaledWeight = @TotalScaledWeight + isnull(@WeightSum, 0)

UPDATE	#PermitHeader
SET PSCSR = @WeightSum

SELECT   @WeightSum = SUM(PAC_ScaledWeight) 
FROM        Permit_Axle_Configuration
WHERE    (P_ID = @P_ID) AND (PAC_ScaledWeightType = 'DRV')

SET @TotalScaledWeight = @TotalScaledWeight + isnull(@WeightSum, 0)

UPDATE	#PermitHeader
SET PSCDR = @WeightSum

SELECT   @WeightSum = SUM(PAC_ScaledWeight) 
FROM        Permit_Axle_Configuration
WHERE    (P_ID = @P_ID) AND (PAC_ScaledWeightType = 'JEEP')

SET @TotalScaledWeight = @TotalScaledWeight + isnull(@WeightSum, 0)

UPDATE	#PermitHeader
SET PSCJP = @WeightSum

SELECT   @WeightSum = SUM(PAC_ScaledWeight) 
FROM        Permit_Axle_Configuration
WHERE    (P_ID = @P_ID) AND (PAC_ScaledWeightType = 'TRL')

SET @TotalScaledWeight = @TotalScaledWeight + isnull(@WeightSum, 0)

UPDATE	#PermitHeader
SET PSCTL = @WeightSum

SELECT   @WeightSum = SUM(PAC_ScaledWeight) 
FROM        Permit_Axle_Configuration
WHERE    (P_ID = @P_ID) AND (PAC_ScaledWeightType = 'STRING')

SET @TotalScaledWeight = @TotalScaledWeight + isnull(@WeightSum, 0)

UPDATE	#PermitHeader
SET PSCST = @WeightSum

--Overall Length should match 'Total Length' value displayed in Axle config.
-- PTS 47339 SGB Added overhang to overall length 
SELECT @OverallLength = isnull(sum(pac_previousdistance) - sum(pac_pad) + sum(isnull(pac_overhang,0)),0)
FROM       Permit_Axle_Configuration
WHERE    (P_ID = @P_ID) AND (asgn_type = 'TRC')

SELECT @OverallLength = @OverallLength + sum(pac_previousdistance) + sum(pac_pad) + sum(isnull(pac_overhang,0))
FROM       Permit_Axle_Configuration
WHERE    (P_ID = @P_ID) AND (asgn_type = 'TRL')

UPDATE #PermitHeader
SET 	OLFT = CAST(ROUND(@OverallLength, 0) AS int) / 12,
 	OLIN = CAST(ROUND(@OverallLength, 0) AS int) % 12

/*
string(int((sum( if(  asgn_type ='TRC',  pac_previousdistance , 0 ) for all ) 
	- sum( if(  asgn_type ='TRC',   pac_pad , 0 ) for all ) 
	+ sum( if(  asgn_type ='TRL',  pac_previousdistance , 0 ) for all ) 
	+ sum( if(  asgn_type ='TRL',   pac_pad , 0 ) for all ) ) /12)) 
	+ "' " 
	+ string(mod((sum( if(  asgn_type ='TRC',  pac_previousdistance , 0 ) for all ) 
	- sum( if(  asgn_type ='TRC',   pac_pad , 0 ) for all ) 
	+ sum( if(  asgn_type ='TRL',  pac_previousdistance , 0 ) for all ) 
	+ sum( if(  asgn_type ='TRL',   pac_pad , 0 ) for all )),12)) + '"'
*/

/*
UPDATE #PermitHeader
SET 	ONAME = cmp.cmp_name,
	OL1 = cmp.cmp_address1,
	OL2 = cmp.cmp_address2,
	OL3 = cmp.cty_nmstct
FROM	Permits AS P INNER JOIN
		legheader AS lgh ON P.lgh_number = lgh.lgh_number INNER JOIN
		company as cmp ON lgh.cmp_id_start = cmp.cmp_id
WHERE	(P.P_ID = @P_ID) 

UPDATE #PermitHeader
SET 	DNAME = cmp.cmp_name,
	DL1 = cmp.cmp_address1,
	DL2 = cmp.cmp_address2,
	DL3 = cmp.cty_nmstct
FROM	Permits AS P INNER JOIN
		legheader AS lgh ON P.lgh_number = lgh.lgh_number INNER JOIN
		company as cmp ON lgh.cmp_id_end = cmp.cmp_id
WHERE	(P.P_ID = @P_ID) 
*/

UPDATE #PermitHeader
SET 	ONAME = ocmp.cmp_name,
	OL1 = ocmp.cmp_address1,
	OL2 = ocmp.cmp_address2,
	OL3 = ocmp.cty_nmstct,
	DNAME = dcmp.cmp_name,
	DL1 = dcmp.cmp_address1,
	DL2 = dcmp.cmp_address2,
	DL3 = dcmp.cty_nmstct
FROM 	Permits P 
	JOIN orderheader o on o.mov_number = @mov_number and o.ord_hdrnumber = @ord_hdrnumber-- PTS 52850(select max(ord_hdrnumber) from stops where stops.mov_number = @mov_number and stops.ord_hdrnumber <> 0)
	JOIN company ocmp on ocmp.cmp_id = o.ord_shipper
	--JOIN city octy on octy.cty_code = ocmp.cmp_city
	JOIN company dcmp on dcmp.cmp_id = o.ord_consignee
	--JOIN city dcty on dcty.cty_code = dcmp.cmp_city
WHERE 	(P.P_ID = @P_ID) 



--Use freightdetail
/*
UPDATE #PermitHeader
SET		LFT = CAST(ROUND(fgt.fgt_length, 0) AS int) / 12,
		LIN = CAST(ROUND(fgt.fgt_length, 0) AS int) % 12,
		WFT = CAST(ROUND(fgt.fgt_width, 0) AS int) / 12,
		WIN = CAST(ROUND(fgt.fgt_width, 0) AS int) % 12,
		HFT = CAST(ROUND(fgt.fgt_height, 0) AS int) / 12,
		HIN = CAST(ROUND(fgt.fgt_height, 0) AS int) % 12
FROM        Permits P INNER JOIN
                     legheader lgh ON P.lgh_number = lgh.lgh_number LEFT OUTER JOIN
                     freightdetail fgt ON lgh.fgt_number = fgt.fgt_number
WHERE    (P.P_ID = @P_ID)
*/

--JLB PTS 41212 rewrote from clause for performance issues
SELECT	@LFT = CAST(ROUND(max(freightdetail.fgt_length), 0) AS int) / 12,
        @LIN = CAST(ROUND(max(freightdetail.fgt_length), 0) AS int) % 12,
        @WFT = CAST(ROUND(max(freightdetail.fgt_width), 0) AS int) / 12,
        @WIN = CAST(ROUND(max(freightdetail.fgt_width), 0) AS int) % 12,
        @HFT = CAST(ROUND(max(freightdetail.fgt_height), 0) AS int) / 12,
        @HIN = CAST(ROUND(max(freightdetail.fgt_height), 0) AS int) % 12
  FROM stops
  join freightdetail on freightdetail.stp_number = stops.stp_number
  join commodity on commodity.cmd_code = freightdetail.cmd_code
WHERE 	((@ord_hdrnumber > 0 AND stops.ord_hdrnumber = @ord_hdrnumber) OR 
	(@lgh_number > 0 AND stops.lgh_number = @lgh_number) OR
        (@mov_number > 0 AND stops.mov_number = @mov_number))
   	AND freightdetail.cmd_code <> 'UNKNOWN'
GROUP BY	cmd_name,
         	cmd_misc1,
         	cmd_misc2,
		cmd_misc3,
		cmd_misc4,
		cmd_default_length,
		cmd_default_width,
		cmd_default_height,
		cmd_default_weight, 
		freightdetail.cmd_code

UPDATE #PermitHeader
SET 	LFT = @LFT,
	LIN = @LIN,
	WFT = @WFT,
	WIN = @WIN,
	HFT = @HFT,
	HIN = @HIN

--Get Load serial number
-- PTS 52850 If there are consolidated orders only use ord_hdrnumber
-- otherwise check leg and move as originally coded
/*
	UPDATE #PermitHeader
		SET LSNBR = LEFT(ref.ref_number, 10) 
		FROM        freightdetail fgt INNER JOIN
												 stops ON fgt.stp_number = stops.stp_number INNER JOIN
												 referencenumber ref ON fgt.fgt_number = ref.ref_tablekey
		WHERE  (stops.stp_sequence = 1) AND 
				(ref.ref_type = 'SER') AND 
				(ref.ref_table = 'freightdetail') AND
				((@ord_hdrnumber > 0 AND stops.ord_hdrnumber = @ord_hdrnumber) OR 
				(@lgh_number > 0 AND stops.lgh_number = @lgh_number) OR
						(@mov_number > 0 AND stops.mov_number = @mov_number))
*/
IF @OrderCount > 1
	BEGIN
		UPDATE #PermitHeader
		SET LSNBR = LEFT(ref.ref_number, 10) 
		FROM        freightdetail fgt INNER JOIN
												 stops ON fgt.stp_number = stops.stp_number INNER JOIN
												 referencenumber ref ON fgt.fgt_number = ref.ref_tablekey
		WHERE  (stops.stp_sequence = 1) AND 
				(ref.ref_type = 'SER') AND 
				(ref.ref_table = 'freightdetail') AND
				(@ord_hdrnumber > 0 AND stops.ord_hdrnumber = @ord_hdrnumber) 
		END 
ELSE
	BEGIN
	UPDATE #PermitHeader
		SET LSNBR = LEFT(ref.ref_number, 10) 
		FROM        freightdetail fgt INNER JOIN
												 stops ON fgt.stp_number = stops.stp_number INNER JOIN
												 referencenumber ref ON fgt.fgt_number = ref.ref_tablekey
		WHERE  (stops.stp_sequence = 1) AND 
				(ref.ref_type = 'SER') AND 
				(ref.ref_table = 'freightdetail') AND
				((@ord_hdrnumber > 0 AND stops.ord_hdrnumber = @ord_hdrnumber) OR 
				(@lgh_number > 0 AND stops.lgh_number = @lgh_number) OR
						(@mov_number > 0 AND stops.mov_number = @mov_number))
	END


INSERT INTO #foroutput
SELECT 	Left(LTrim(isNull(LOGNUM, '')) + Space(5), 5) +
	Left(LTrim(isNull(RCDCD, '')) + Space(2), 2) +
	Left(LTrim(isNull(LINENUM, '')) + Space(2), 2) +
	Left(LTrim(isNull(CMNAME, '')) + Space(30), 30) +
	Left(LTrim(isNull(ACCTNO, '')) + Space(6), 6) +
	Left(LTrim(isNull(TRIPNO, '')) + Space(7), 7) +
	Left(LTrim(isNull(PERMITDATE, '')) + Space(6), 6) +
	Left(LTrim(isNull(PERMITTIME, '')) + Space(6), 6) +
	Left(LTrim(isNull(DRNAME, '')) + Space(25), 25) +
	Left(LTrim(isNull(LDDESC, '')) + Space(20), 20) +
	Right(Space(6) + LTrim(RTrim(isNull(UNIT, ''))), 6) +
	Left(LTrim(isNull(LSNBR, '')) + Space(10), 10) +
	Right(Space(6) + LTrim(RTrim(isNull(TRLR, ''))), 6) +
	Left(LTrim(isNull(EQ1, '')) + Space(6), 6) +
	Left(LTrim(isNull(EQ2, '')) + Space(6), 6) +
	Left(LTrim(isNull(EQ3, '')) + Space(6), 6) +
	Left(LTrim(isNull(EQ4, '')) + Space(6), 6) +
	Left(LTrim(isNull(EQ5, '')) + Space(6), 6) +
	Left(LTrim(isNull(EQ6, '')) + Space(6), 6) +
	Left(LTrim(isNull(ONAME, '')) + Space(25), 25) +
	Left(LTrim(isNull(OL1, '')) + Space(25), 25) +
	Left(LTrim(isNull(OL2, '')) + Space(25), 25) +
	Left(LTrim(isNull(OL3, '')) + Space(25), 25) +
	Left(LTrim(isNull(DNAME, '')) + Space(25), 25) +
	Left(LTrim(isNull(DL1, '')) + Space(25), 25) +
	Left(LTrim(isNull(DL2, '')) + Space(25), 25) +
	Left(LTrim(isNull(DL3, '')) + Space(25), 25) +
	Left(LTrim(isNull(UYR, '')) + Space(2), 2) +
	Left(LTrim(isNull(UMAK, '')) + Space(12), 12) +
	Left(LTrim(isNull(ULIC, '')) + Space(8), 8) +
	Left(LTrim(isNull(USNBR, '')) + Space(19), 19) +
	Left(LTrim(isNull(UWGT, '')) + Space(5), 5) +
	Left(LTrim(isNull(TYR, '')) + Space(2), 2) +
	Left(LTrim(isNull(TMAK, '')) + Space(12), 12) +
	Left(LTrim(isNull(TLIC, '')) + Space(8), 8) +
	Left(LTrim(isNull(TSNBR, '')) + Space(19), 19) +
	Right('00000' + RTrim(isNull(TWGT, '')), 5) +
	Right('00' + RTrim(isNull(UFT1, '')), 2) +
	Right('00' + RTrim(isNull(UIN1, '')), 2) +
	Right('00' + RTrim(isNull(UFT2, '')), 2) +
	Right('00' + RTrim(isNull(UIN2, '')), 2) +
	Right('00' + RTrim(isNull(UFT3, '')), 2) +
	Right('00' + RTrim(isNull(UIN3, '')), 2) +
	Right('00' + RTrim(isNull(UFT4, '')), 2) +
	Right('00' + RTrim(isNull(UIN4, '')), 2) +
	Right('00' + RTrim(isNull(TFT1, '')), 2) +
	Right('00' + RTrim(isNull(TIN1, '')), 2) +
	Right('00' + RTrim(isNull(TFT2, '')), 2) +
	Right('00' + RTrim(isNull(TIN2, '')), 2) +
	Right('00' + RTrim(isNull(TFT3, '')), 2) +
	Right('00' + RTrim(isNull(TIN3, '')), 2) +
	Right('00' + RTrim(isNull(TFT4, '')), 2) +
	Right('00' + RTrim(isNull(TIN4, '')), 2) +
	Right('000' + RTrim(isNull(TFT, '')), 3) +
	Right('00' + RTrim(isNull(TIN, '')), 2) +
	Right('0000000000' + RTrim(isNull(UTSZ, '')), 10) +
	Right('0000000000' + RTrim(isNull(TTSZ, '')), 10) +
	Right('0000000' + RTrim(isNull(PGRWT, '')), 7) +
	Right('0000000' + RTrim(isNull(PTWGT, '')), 7) +
	Right('000000' + RTrim(isNull(TWGTS, '')), 6) +
	Right('00' + RTrim(isNull(TAXLE, '')), 2) +
	Right('00000' + RTrim(isNull(PSCSR, '')), 5) +
	Right('00000' + RTrim(isNull(PSCDR, '')), 5) +
	Right('00000' + RTrim(isNull(PSCJP, '')), 5) +
	Right('00000' + RTrim(isNull(PSCTL, '')), 5) +
	Right('00000' + RTrim(isNull(PSCST, '')), 5) +
	Right('000' + RTrim(isNull(LFT, '')), 3) +
	Right('00' + RTrim(isNull(LIN, '')), 2) +
	Right('00' + RTrim(isNull(WFT, '')), 2) +
	Right('00' + RTrim(isNull(WIN, '')), 2) +
	Right('00' + RTrim(isNull(HFT, '')), 2) +
	Right('00' + RTrim(isNull(HIN, '')), 2) +
	Right('000' + RTrim(isNull(OLFT, '')), 3) +
	Right('00' + RTrim(isNull(OLIN, '')), 2) +
	Right('00' + RTrim(isNull(OWFT, '')), 2) +
	Right('00' + RTrim(isNull(OWIN, '')), 2) +
	Right('00' + RTrim(isNull(OHFT, '')), 2) +
	Right('00' + RTrim(isNull(OHIN, '')), 2) + 
	Replicate('@', 2) + 
	@RecordTerminator
FROM #PermitHeader

INSERT INTO #PermitOrderInfo(
	LOGNUM,
	RCDCD,
	LINENUM,
	STATE,
	ROUTE,
	RDATE,
	ATTN,
	PFAC,
	PFNBR,
	UDATE,
	EXDT,
	TOTW,
	AX1,
	AX2,
	AX3,
	AX4,
	AX5,
	INTLS,
	PTYPE
)
SELECT	@LogNumOut AS LOGNUM, 
		'04' AS RCDCD, 
		'01' AS LINENUM, 
		PM.PM_Comment1 AS STATE, 
		'' AS ROUTE, 
		'' AS RDATE, 
		'' AS ATTN, 
		'' AS PFAC, 
		'' AS PFNBR, 
		RIGHT(CONVERT(char(6), GETDATE(), 12), 4) + LEFT(CONVERT(char(6), GETDATE(), 12), 2) AS UDATE, 
		'' AS EXDT, 
		'' AS TOTW, 
		'' AS AX1, 
		'' AS AX2, 
		'' AS AX3, 
		'' AS AX4, 
		'' AS AX5, 
		LEFT(P.p_createby, 3) AS INTLS, 
		'' AS PTYPE
FROM	Permits P INNER JOIN
		Permit_Master PM ON P.PM_ID = PM.PM_ID
WHERE	(P.P_ID = @P_ID)

--Walk through route info to build route string'
IF EXISTS(SELECT P_ID FROM Permit_Route_Altered WHERE P_ID = @P_ID) BEGIN
	SET @recordptr_route = 1
	SELECT @recordcount_route = count(*)
	FROM	Permit_Route_Detail_Altered PRDA INNER JOIN
			Permit_Route_Altered PRTA ON PRDA.PRTA_ID = PRTA.PRTA_ID
	WHERE	(PRTA.P_ID = @P_ID)

	SET @routedetail_line = ''
	SET @routeseparator = ''
	WHILE (@recordptr_route <= @recordcount_route) BEGIN
		SELECT	@route_name = ISNULL(PRTA.PRTA_Name, ''),
			@routedetail_Route = ISNULL(PRDA.PRDA_Route, ''), 
			@routedetail_Direction = ISNULL(PRDA.PRDA_Direction, ''), 
			@routedetail_ToIntersection = ISNULL(PRDA.PRDA_ToIntersection, '')
		FROM	Permit_Route_Detail_Altered PRDA INNER JOIN
				Permit_Route_Altered PRTA ON PRDA.PRTA_ID = PRTA.PRTA_ID
		WHERE	(PRTA.P_ID = @P_ID) AND 
			PRDA.PRDA_Sequence = @recordptr_route

		IF @routedetail_line = '' BEGIN
			SET @routedetail_line = @routedetail_line + @route_name + '  '
		END
		SET @routedetail_line = @routedetail_line + @routeseparator + @routedetail_Route + @routedetail_Direction 
		SET @routeseparator = '-'
		IF @routedetail_ToIntersection <> '' BEGIN
			SET @routedetail_line = @routedetail_line + @routeseparator + @routedetail_ToIntersection 
		END
		
		SET @recordptr_route = @recordptr_route + 1
	END
		

END
ELSE BEGIN

	SET @recordptr_route = 1
	SELECT @recordcount_route = count(*)
	FROM	Permit_Route_Detail PRD INNER JOIN
			Permit_Route PRT ON PRD.PRT_ID = PRT.PRT_ID INNER JOIN
			Permits P ON PRT.PRT_ID = P.PRT_ID
	WHERE	(P.P_ID = @P_ID)  

	SET @routedetail_line = ''
	SET @routeseparator = ''
	WHILE (@recordptr_route <= @recordcount_route) BEGIN
		SELECT	@route_name = ISNULL(PRT.PRT_Name, ''),
			@routedetail_Route = ISNULL(PRD.PDR_Route, ''), 
			@routedetail_Direction = ISNULL(PRD.PDR_Direction, ''), 
			@routedetail_ToIntersection = ISNULL(PRD.PDR_ToIntersection, '')
		FROM	Permit_Route_Detail PRD INNER JOIN
				Permit_Route PRT ON PRD.PRT_ID = PRT.PRT_ID INNER JOIN
				Permits P ON PRT.PRT_ID = P.PRT_ID
		WHERE	(P.P_ID = @P_ID) AND 
			PRD.PDR_Sequence = @recordptr_route

		IF @routedetail_line = '' BEGIN
			SET @routedetail_line = @routedetail_line + @route_name + '  '
		END
		SET @routedetail_line = @routedetail_line + @routeseparator + @routedetail_Route + @routedetail_Direction 
		SET @routeseparator = '-'
		IF @routedetail_ToIntersection <> '' BEGIN
			SET @routedetail_line = @routedetail_line + @routeseparator + @routedetail_ToIntersection 
		END
		
		SET @recordptr_route = @recordptr_route + 1
	END


END

UPDATE #PermitOrderInfo 
	SET ROUTE = @routedetail_line

/*
IF EXISTS(SELECT P_ID FROM Permit_Route_Altered WHERE P_ID = @P_ID) BEGIN
	INSERT INTO #PermitOrderInfo(
		LOGNUM,
		RCDCD,
		LINENUM,
		STATE,
		ROUTE,
		RDATE,
		ATTN,
		PFAC,
		PFNBR,
		UDATE,
		EXDT,
		TOTW,
		AX1,
		AX2,
		AX3,
		AX4,
		AX5,
		INTLS,
		PTYPE
	)
	SELECT	@LogNumOut AS LOGNUM, 
			'04' AS RCDCD, 
			RIGHT('0' + CAST(PRDA.PRDA_Sequence AS varchar(2)), 2) AS LINENUM, 
			'' AS STATE, 
			PRDA.PRDA_Route AS ROUTE, 
			'' AS RDATE, 
			'' AS ATTN, 
			'' AS PFAC, 
			'' AS PFNBR, 
			RIGHT(CONVERT(char(6), GETDATE(), 12), 4) + LEFT(CONVERT(char(6), GETDATE(), 12), 2) AS UDATE, 
			'' AS EXDT, 
			'' AS TOTW, 
			'' AS AX1, 
			'' AS AX2, 
			'' AS AX3, 
			'' AS AX4, 
			'' AS AX5, 
			'' AS INTLS, 
			'' AS PTYPE
	FROM	Permit_Route_Detail_Altered PRDA INNER JOIN
			Permit_Route_Altered PRTA ON PRDA.PRTA_ID = PRTA.PRTA_ID
	WHERE	(PRTA.P_ID = @P_ID)
	ORDER BY PRDA.PRDA_Sequence
END
ELSE BEGIN
	INSERT INTO #PermitOrderInfo(
		LOGNUM,
		RCDCD,
		LINENUM,
		STATE,
		ROUTE,
		RDATE,
		ATTN,
		PFAC,
		PFNBR,
		UDATE,
		EXDT,
		TOTW,
		AX1,
		AX2,
		AX3,
		AX4,
		AX5,
		INTLS,
		PTYPE
	)
	SELECT	@LogNumOut AS LOGNUM, 
			'04' AS RCDCD, 
			RIGHT('0' + CAST(PDR.PDR_Sequence AS varchar(2)), 2) AS LINENUM, 
			'' AS STATE, 
			PDR.PDR_Route AS ROUTE, 
			'' AS RDATE, 
			'' AS ATTN, 
			'' AS PFAC, 
			'' AS PFNBR, 
			RIGHT(CONVERT(char(6), GETDATE(), 12), 4) + LEFT(CONVERT(char(6), GETDATE(), 12), 2) AS UDATE, 
			'' AS EXDT, 
			'' AS TOTW, 
			'' AS AX1, 
			'' AS AX2, 
			'' AS AX3, 
			'' AS AX4, 
			'' AS AX5, 
			'' AS INTLS, 
			'' AS PTYPE
	FROM	Permit_Route_Detail PDR INNER JOIN
			Permit_Route PRT ON PDR.PRT_ID = PRT.PRT_ID INNER JOIN
			Permits P ON PRT.PRT_ID = P.PRT_ID
	WHERE	(P.P_ID = @P_ID)
	ORDER BY PDR.PDR_Sequence
END
*/

UPDATE #PermitOrderInfo
SET ATTN = 'SEE COMMENTS'


--Get fax to info
SELECT	@P_Transmit_To_Type = P_Transmit_To_Type, 
		@P_Transmit_To = P_Transmit_To, 
		@P_Transmit_Method = P_Transmit_Method
FROM	Permits
WHERE	(P_ID = @P_ID)


--Set Fax info
IF @P_Transmit_Method = 'FAX' BEGIN
		IF @P_Transmit_To_Type = 'TRCSTP' BEGIN
			SELECT    @FaxNumber = ts_fax_number
			FROM        truckstops
			WHERE    (ts_code = @P_Transmit_To) 
			IF len(@FaxNumber) = 10 BEGIN
				SELECT @FaxAreaCode = LEFT(@FaxNumber, 3)
				SELECT @FaxPrefixNumber = RIGHT(@FaxNumber, 7)
			END
		END
		--ELSE IF @P_Transmit_To_Type = 'DRV' BEGIN
		--END
		--ELSE IF @P_Transmit_To_Type = 'TRC' BEGIN
		--END
		ELSE IF @P_Transmit_To_Type = 'CMP' BEGIN
			SELECT    @FaxNumber = cmp_faxphone
			FROM      company
			WHERE    (cmp_id = @P_Transmit_To) 
			IF len(@FaxNumber) = 10 BEGIN
				SELECT @FaxAreaCode = LEFT(@FaxNumber, 3)
				SELECT @FaxPrefixNumber = RIGHT(@FaxNumber, 7)
			END
		END
		IF @FaxAreaCode IS NOT NULL AND @FaxPrefixNumber IS NOT NULL BEGIN
			UPDATE #PermitOrderInfo
			SET PFAC = @FaxAreaCode,
				PFNBR = @FaxPrefixNumber
		END
END


SET @CurrentAxle = 0
SET @AxleWeight = null
SELECT TOP 1 @AxleWeight = PAC.PAC_MaxWeight,
		@CurrentAxle = PAC.PAC_AxleNumber
FROM        Permit_Axle_Configuration PAC 
WHERE    (PAC.P_ID = @P_ID)  
		AND PAC.PAC_AxleNumber > @CurrentAxle
		AND PAC.PAC_MaxWeight > 0 
ORDER BY  PAC.PAC_AxleNumber	

UPDATE   #PermitOrderInfo
SET       AX1 = ROUND((ISNULL(@AxleWeight, 0) / 1000), 0)

SET @AxleWeight = null
SELECT TOP 1 @AxleWeight = PAC.PAC_MaxWeight,
		@CurrentAxle = PAC.PAC_AxleNumber
FROM        Permit_Axle_Configuration PAC 
WHERE    (PAC.P_ID = @P_ID)  
		AND PAC.PAC_AxleNumber > @CurrentAxle
		AND PAC.PAC_MaxWeight > 0 
ORDER BY  PAC.PAC_AxleNumber	

UPDATE   #PermitOrderInfo
SET       AX2 = ROUND((ISNULL(@AxleWeight, 0) / 1000), 0)

SET @AxleWeight = null
SELECT TOP 1 @AxleWeight = PAC.PAC_MaxWeight,
		@CurrentAxle = PAC.PAC_AxleNumber
FROM        Permit_Axle_Configuration PAC 
WHERE    (PAC.P_ID = @P_ID)  
		AND PAC.PAC_AxleNumber > @CurrentAxle
		AND PAC.PAC_MaxWeight > 0 
ORDER BY  PAC.PAC_AxleNumber	

UPDATE   #PermitOrderInfo
SET       AX3 = ROUND((ISNULL(@AxleWeight, 0) / 1000), 0)

SET @AxleWeight = null
SELECT TOP 1 @AxleWeight = PAC.PAC_MaxWeight,
		@CurrentAxle = PAC.PAC_AxleNumber
FROM        Permit_Axle_Configuration PAC 
WHERE    (PAC.P_ID = @P_ID)  
		AND PAC.PAC_AxleNumber > @CurrentAxle
		AND PAC.PAC_MaxWeight > 0 
ORDER BY  PAC.PAC_AxleNumber	

UPDATE   #PermitOrderInfo
SET       AX4 = ROUND((ISNULL(@AxleWeight, 0) / 1000), 0)

SET @AxleWeight = null
SELECT TOP 1 @AxleWeight = PAC.PAC_MaxWeight,
		@CurrentAxle = PAC.PAC_AxleNumber
FROM        Permit_Axle_Configuration PAC 
WHERE    (PAC.P_ID = @P_ID)  
		AND PAC.PAC_AxleNumber > @CurrentAxle
		AND PAC.PAC_MaxWeight > 0 
ORDER BY  PAC.PAC_AxleNumber	

UPDATE   #PermitOrderInfo
SET       AX5 = ROUND((ISNULL(@AxleWeight, 0) / 1000), 0)

SELECT @WeightSum = SUM(PAC.PAC_MaxWeight)
FROM        Permit_Axle_Configuration PAC 
WHERE    (PAC.P_ID = @P_ID) 

UPDATE   #PermitOrderInfo
SET      TOTW = @WeightSum


UPDATE	#PermitOrderInfo
SET     	RDATE = RIGHT(CONVERT(char(6), P.P_Valid_From, 12), 4) + LEFT(CONVERT(char(6), P.P_Valid_From, 12), 2),
		EXDT = RIGHT(CONVERT(char(6), P.P_Valid_To, 12), 4) + LEFT(CONVERT(char(6), P.P_Valid_To, 12), 2)
FROM        Permits P 
WHERE    (P.P_ID = @P_ID)

--Set Permit Type (If blanket, set = 'BLKT')
UPDATE #PermitOrderInfo
	SET PTYPE = 'BLKT'
	FROM Permits
	WHERE  P_ID = @P_ID AND
			(ISNULL(ord_hdrnumber, 0) = 0) AND
			( ISNULL(mov_number, 0) = 0) AND
			( ISNULL(ord_hdrnumber, 0) = 0) 
			
INSERT INTO #foroutput
SELECT 	Left(LTrim(isNull(LOGNUM, '')) + Space(5), 5) +
	Left(LTrim(isNull(RCDCD, '')) + Space(2), 2) +
	Left(LTrim(isNull(LINENUM, '')) + Space(2), 2) +
	Left(LTrim(isNull(STATE, '')) + Space(2), 2) +
	Left(LTrim(isNull(ROUTE, '')) + Space(72), 72) +
	Left(LTrim(isNull(RDATE, '')) + Space(6), 6) +
	Left(LTrim(isNull(ATTN, '')) + Space(30), 30) +
	Left(LTrim(isNull(PFAC, '')) + Space(3), 3) +
	Right('0000000' + RTrim(isNull(PFNBR, '')), 7) +
	Left(LTrim(isNull(UDATE, '')) + Space(6), 6) +
	Left(LTrim(isNull(EXDT, '')) + Space(6), 6) +
	Right('000000' + RTrim(isNull(TOTW, '')), 6) +
	Right('00' + RTrim(isNull(AX1, '')), 2) +
	Right('00' + RTrim(isNull(AX2, '')), 2) +
	Right('00' + RTrim(isNull(AX3, '')), 2) +
	Right('00' + RTrim(isNull(AX4, '')), 2) +
	Right('00' + RTrim(isNull(AX5, '')), 2) +
	Left(LTrim(isNull(INTLS, '')) + Space(3), 3) +
	Left(LTrim(isNull(PTYPE, '')) + Space(5), 5) +
	Space(2) + 
	Replicate('@', 2) +
	Space(422) + 
	@RecordTerminator
FROM #PermitOrderInfo

INSERT INTO #PermitComments(
	LOGNUM, 
	RCDCD,
	LINENUM,
	CMT1,
	CMT2,
	CMT3,
	NPERM, 
	FDLOG  
)
SELECT	@LogNumOut AS LOGNUM, 
		'05' AS RCDCD, 
		'00' AS LINENUM, 
		'' AS CMT1, 
		'' AS CMT2, 
		Left(ISNULL(p_comdata_comment, ''), 75) AS CMT3, 
		1 AS NPERM, 
		@LogNumOut AS FDLOG
FROM	Permits AS P
WHERE	(P_ID = @P_ID)


--Get fax to info
--SELECT	@P_Transmit_To_Type = P_Transmit_To_Type, 
--		@P_Transmit_To = P_Transmit_To, 
--		@P_Transmit_Method = P_Transmit_Method
--FROM	Permits
--WHERE	(P_ID = @P_ID)

--Set Fax info
IF @P_Transmit_Method = 'FAX' BEGIN
		IF @P_Transmit_To_Type = 'TRCSTP' BEGIN
			SELECT	@FaxToName = ts_name,
				@FaxToCityStateZip = LEFT(RTRIM(ISNULL(ts_city, '')) + ', ' + RTRIM(ISNULL(ts_state, '')) + ' ' + RTRIM(ISNULL(ts_zip_code, '')), 75)
			FROM        truckstops
			WHERE    (ts_code = @P_Transmit_To) 
		END
		--ELSE IF @P_Transmit_To_Type = 'DRV' BEGIN
		--END
		--ELSE IF @P_Transmit_To_Type = 'TRC' BEGIN
		--END
		ELSE IF @P_Transmit_To_Type = 'CMP' BEGIN
			SELECT    @FaxToName = LEFT(ISNULL(cmp_name, ''), 75),
				  @FaxToCityStateZip = LEFT(RTRIM(ISNULL(city.cty_name, '')) + ', ' + RTRIM(ISNULL(city.cty_state, '')) + ' ' + RTRIM(ISNULL(city.cty_zip, '')), 75)
			FROM      company LEFT JOIN city on company.cmp_city = city.cty_code
			WHERE    (cmp_id = @P_Transmit_To) 
		END
		
		UPDATE #PermitComments
		SET 	CMT1 = ISNULL(@FaxToName, ''),
			CMT2 = ISNULL(@FaxToCityStateZip, '')


END




INSERT INTO #foroutput
SELECT 	Left(LTrim(isNull(LOGNUM, '')) + Space(5), 5) +
	Left(LTrim(isNull(RCDCD, '')) + Space(2), 2) +
	Left(LTrim(isNull(LINENUM, '')) + Space(2), 2) +
	Left(LTrim(isNull(CMT1, '')) + Space(75), 75) +
	Left(LTrim(isNull(CMT2, '')) + Space(75), 75) +
	Left(LTrim(isNull(CMT3, '')) + Space(75), 75) +
	Right('0000' + RTrim(isNull(NPERM, '')), 4) +
	Left(LTrim(isNull(FDLOG, '')) + Space(5), 5) +
	Space(2) +
	Replicate('@', 2) +
	Space(344) +
	@RecordTerminator
FROM #PermitComments



INSERT INTO #PermitRequiredStates(
	LOGNUM,
	RCDCD,
	LINENUM,
	ST01,
	ST02,
	ST03,
	ST04,
	ST05,
	ST06,
	ST07,
	ST08
)
SELECT	@LogNumOut as LOGNUM,
		'06' as RCDCD,
		'00' as LINENUM,
		'' as ST01,
		'' as ST02,
		'' as ST03,
		'' as ST04,
		'' as ST05,
		'' as ST06,
		'' as ST07,
		'' as ST08


UPDATE	#PermitRequiredStates
SET		ST01 = PM.PM_Comment1
FROM	Permits P INNER JOIN
		Permit_Master PM ON P.PM_ID = PM.PM_ID
WHERE	(P.P_ID = @P_ID)


INSERT INTO #foroutput
SELECT 	Left(LTrim(isNull(LOGNUM, '')) + Space(5), 5) +
	Left(LTrim(isNull(RCDCD, '')) + Space(2), 2) +
	Left(LTrim(isNull(LINENUM, '')) + Space(2), 2) +
	Left(LTrim(isNull(ST01, '')) + Space(2), 2) +
	Left(LTrim(isNull(ST02, '')) + Space(2), 2) +
	Left(LTrim(isNull(ST03, '')) + Space(2), 2) +
	Left(LTrim(isNull(ST04, '')) + Space(2), 2) +
	Left(LTrim(isNull(ST05, '')) + Space(2), 2) +
	Left(LTrim(isNull(ST06, '')) + Space(2), 2) +
	Left(LTrim(isNull(ST07, '')) + Space(2), 2) +
	Left(LTrim(isNull(ST08, '')) + Space(2), 2) +
	Space(2) + 
	Replicate('@', 2) +
	Space(562) +
	@RecordTerminator
FROM #PermitRequiredStates


/*

--Each transmission must begin with and contain only one header record.
create table #HeaderRecord(
	RECORD_ID	char(2),	--constant 'HR'
	CUSTOMER_NBR	char(6),	--Comdata account number
	LOG_NBR		char(5),	--Unique identifier for transmission
	REFERENCE_NBR_1	char(10),	--customer cross reference value 1
	REFERENCE_NBR_2	char(20),	--customer cross reference value 2
	DRIVER_NAME	char(45),	--driver's name
	CONTACT_NAME	char(15),	--contact name 									
	CONTACT_PHONE	char(10),	--contact's phone number 									
	EXTENSION	char(6),	--contact's phone number extension									
	EMAIL_ADDRESS	char(60),	--email address									
	CARRIER_NAME	char(45),
	CARRIER_ADDRESS	char(45),
	CARRIER_CITY	char(20),
	CARRIER_ZIP	char(10),
	FILLER		char(200),	--room for future expansion									
)

--Each transmission must contain a load record.
create table #LoadRecord(
	RECORD_ID		char(2),	--constant 'LR' 									
	LOAD_DESCRIPTION	char(45),	--Description 									
	LOAD_SERIAL_NBR		char(21),	--Serial number 									
	LOAD_WEIGHT		char(6),	--Load weight (FORMAT NNNNNN or LEGAL)									
	LOAD_WIDTH		char(6),	--Load width   (FORMAT FFF_II or LEGAL)									
	LOAD_LENGTH		char(6),	--Load length  (FORMAT FFF-II or LEGAL)									
	LOAD_HEIGHT		char(6),	--Load height  (FORMAT FFF-II or LEGAL)									
	OVER_ALL_WIDTH		char(6),	--Over all width   (FORMAT FFF-II or LEGAL)									
	OVER_ALL_LENGTH		char(6),	--Over all length  (FORMAT FFF-II or LEGAL)									
	OVER_ALL_HEIGHT		char(6),	--Over all height  (FORMAT FFF-II or LEGAL)									
	ACT_GROSS_WEIGHT	char(6),	--Actual gross weight 									
	NBR_OF_PIECES		char(2),	--Number of loaded pieces									
	LOAD_MAKE		char(20),	--Make of load									
	LOAD_MODEL_NBR		char(10),	--Load model									
	FRONT_OVERHANG		char(6),	--Front Overhang (FORMAT FFF-II)									
	READ_OVERHANG		char(6),	--Rear Overhang (FORMAT FFF-II)									
	FILLER			char(339),	--room for future expansion									
)

--Each transmission must contain a shipper record.
create table #ShipperRecord(
	RECORD_ID		char(2),	--constant 'SR' 									
	SHIPPER_NAME		char(45),	--Shipper name									
	SHIPPER_PHONE		char(45),	--Shipper phone number 									
	SHIPPER_ADDRESS		char(45),	--Shipper address									
	SHIPPER_CITY_STATE	char(45),	--Shipper city and state									
	FILLER			char(317),	--room for future expansion									
)

--Each transmission must contain a receiver record.
create table #ReceiverRecord(
	RECORD_ID		char(2),	--constant 'RR' 									
	RECEIVER_NAME		char(45),	--Receiver name									
	RECEIVER_PHONE		char(45),	--Receiver phone number									
	RECEIVER_ADDRESS	char(45),	--Receiver  address									
	RECEIVER_CITY_STATE	char(45),	--Receiver city and state									
	FILLER			char(317)	--room for future expansion									
)

--Each transmission must contain an equipment record.
create table #EquipmentRecord(
	RECORD_ID		char(2),	--constant 'ER' 									
	TRACTOR_NBR		char(8),	--Tractor unit number									
	TRACTOR_YEAR		char(2),	--Tractor year									
	TRACTOR_MAKE		char(8),	--Tractor make									
	TRACTOR_LICENSE_NBR	char(8),	--Tractor license number									
	TRACTOR_LICENSE_ST	char(2),	--Tractor license state									
	TRACTOR_SERIAL_NBR	char(21),	--Tractor serial number									
	TRACTOR_WEIGHT		char(6),	--Tractor weight									
	TRACTOR_AXLES		char(2),	--Tractor number of axles									
	TRAILER_NBR		char(8),	--Trailer unit number									
	TRAILER_YEAR		char(2),	--Trailer year									
	TRAILER_MAKE		char(8),	--Trailer make									
	TRAILER_LICENSE_NBR	char(8),	--Trailer license number									
	TRAILER_LICENSE_ST	char(2),	--Trailer license state									
	TRAILER_SERIAL_NBR	char(21),	--Trailer serial number									
	TRAILER_WEIGHT		char(6),	--Trailer weight									
	TRAILER_AXLES		char(2),	--Trailer number of axles									
	OTHER_NBR		char(8),	--Other unit number									
	OTHER_YEAR		char(2),	--Other year									
	OTHER_MAKE		char(8),	--Other make									
	OTHER_LICENSE_NBR	char(8),	--Other license number									
	OTHER_LICENSE_ST	char(2),	--Other license state									
	OTHER_SERIAL_NBR	char(21),	--Other serial number									
	OTHER_WEIGHT		char(6),	--Other weight									
	OTHER_AXLES		char(2),	--Other number of axles									
	FILLER			char(326)	--room for future expansion									
)

--Each transmission must contain an axle record.
create table #AxleRecord(
	RECORD_ID		char(2),	--constant 'AR' 									
	NBR_OF_TIRES_1		char(2),	--tires per axle 1
	NBR_OF_TIRES_2		char(2),	--tires per axle 2
	NBR_OF_TIRES_3		char(2),	--tires per axle 3
	NBR_OF_TIRES_4		char(2),	--tires per axle 4
	NBR_OF_TIRES_5		char(2),	--tires per axle 5
	NBR_OF_TIRES_6		char(2),	--tires per axle 6
	NBR_OF_TIRES_7		char(2),	--tires per axle 7
	NBR_OF_TIRES_8		char(2),	--tires per axle 8
	NBR_OF_TIRES_9		char(2),	--tires per axle 9
	NBR_OF_TIRES_10		char(2),	--tires per axle 10
	NBR_OF_TIRES_11		char(2),	--tires per axle 11
	NBR_OF_TIRES_12		char(2),	--tires per axle 12
	TIRE_SIZE_1		char(10),	--tire sizes 1
	TIRE_SIZE_2		char(10),	--tire sizes 2
	TIRE_SIZE_3		char(10),	--tire sizes 3
	TIRE_SIZE_4		char(10),	--tire sizes 4
	TIRE_SIZE_5		char(10),	--tire sizes 5
	TIRE_SIZE_6		char(10),	--tire sizes 6
	TIRE_SIZE_7		char(10),	--tire sizes 7
	TIRE_SIZE_8		char(10),	--tire sizes 8
	TIRE_SIZE_9		char(10),	--tire sizes 9
	TIRE_SIZE_10		char(10),	--tire sizes 10
	TIRE_SIZE_11		char(10),	--tire sizes 11
	TIRE_SIZE_12		char(10),	--tire sizes 12
	AXLE_SPACING_1		char(5),	--axle spacing 1
	AXLE_SPACING_2		char(5),	--axle spacing 2
	AXLE_SPACING_3		char(5),	--axle spacing 3
	AXLE_SPACING_4		char(5),	--axle spacing 4
	AXLE_SPACING_5		char(5),	--axle spacing 5
	AXLE_SPACING_6		char(5),	--axle spacing 6
	AXLE_SPACING_7		char(5),	--axle spacing 7
	AXLE_SPACING_8		char(5),	--axle spacing 8
	AXLE_SPACING_9		char(5),	--axle spacing 9
	AXLE_SPACING_10		char(5),	--axle spacing 10
	AXLE_SPACING_11		char(5),	--axle spacing 11
	AXLE_WEIGHT_1		char(6),	--axle weight 1
	AXLE_WEIGHT_2		char(6),	--axle weight 2
	AXLE_WEIGHT_3		char(6),	--axle weight 3
	AXLE_WEIGHT_4		char(6),	--axle weight 4
	AXLE_WEIGHT_5		char(6),	--axle weight 5
	AXLE_WEIGHT_6		char(6),	--axle weight 6
	AXLE_WEIGHT_7		char(6),	--axle weight 7
	AXLE_WEIGHT_8		char(6),	--axle weight 8
	AXLE_WEIGHT_9		char(6),	--axle weight 9
	AXLE_WEIGHT_10		char(6),	--axle weight 10
	AXLE_WEIGHT_11		char(6),	--axle weight 11
	AXLE_WEIGHT_12		char(6),	--axle weight 12
	FILLER			char(226)	--room for future expansion
)

--Each transmission may contain from one to thirty permit records. 
create table #PermitRecord(
	RECORD_ID		char(2),	--constant 'PR' 									
	PERMIT_TYPE		char(5),	--specifies permit type to be ordered by Comdata									
	ACTION_CODE		char(1),	--specifies action for Comdata									
						--	O = Order the permit									
						--	C = Order the permit 									
						--	X = Omit the permit									
						--	R = Revision/Amendment									
						--	A = Advisory for state direct									
	DESTINATION_FAX		char(10),	--fax number to deliver completed permit to									
	EFFECTIVE_DATE		char(6),	--effective date (FORMAT MMDDYY)									
	ACTUAL_GROSS_WT		char(6),	--actual gross weight if different form LOAD_REC									

						--The following twelve fields over-ride the values specified
						--in the AXLE RECORD for this permit if present.
	AXLE_WEIGHT_1		char(6),	--axle weight 1
	AXLE_WEIGHT_2		char(6),	--axle weight 2
	AXLE_WEIGHT_3		char(6),	--axle weight 3
	AXLE_WEIGHT_4		char(6),	--axle weight 4
	AXLE_WEIGHT_5		char(6),	--axle weight 5
	AXLE_WEIGHT_6		char(6),	--axle weight 6
	AXLE_WEIGHT_7		char(6),	--axle weight 7
	AXLE_WEIGHT_8		char(6),	--axle weight 8
	AXLE_WEIGHT_9		char(6),	--axle weight 9
	AXLE_WEIGHT_10		char(6),	--axle weight 10
	AXLE_WEIGHT_11		char(6),	--axle weight 11
	AXLE_WEIGHT_12		char(6),	--axle weight 12
	REMARKS			char(45),	--remarks/comments to appear on permit
	ROUTES_LINE_1		char(45),	--routes line 1
	ROUTES_LINE_2		char(45),	--routes line 2
	ROUTES_LINE_3		char(45),	--routes line 3
	COMMENTS_1		char(45),	--comments/special requirements for Comdata
	COMMENTS_2		char(45),	--comments/special requirements for Comdata
	ACCOUNT_NUMBER		char(20),	--state required account number
	FILLER			char(117)	--room for future expansion
)


--Now Collect the information to be written out...

--Each transmission must begin with and contain only one header record.
INSERT INTO #HeaderRecord(
	RECORD_ID,
	CUSTOMER_NBR,
	LOG_NBR,
	REFERENCE_NBR_1,
	REFERENCE_NBR_2,
	DRIVER_NAME,
	CONTACT_NAME,
	CONTACT_PHONE,
	EXTENSION,
	EMAIL_ADDRESS,
	CARRIER_NAME,
	CARRIER_ADDRESS,
	CARRIER_CITY,
	CARRIER_ZIP,
	FILLER)
SELECT 	'HR',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	''

--Each transmission must contain a load record.
INSERT INTO  #LoadRecord(
	RECORD_ID,
	LOAD_DESCRIPTION,
	LOAD_SERIAL_NBR,
	LOAD_WEIGHT,
	LOAD_WIDTH,
	LOAD_LENGTH,
	LOAD_HEIGHT,
	OVER_ALL_WIDTH,
	OVER_ALL_LENGTH,
	OVER_ALL_HEIGHT,
	ACT_GROSS_WEIGHT,
	NBR_OF_PIECES,
	LOAD_MAKE,
	LOAD_MODEL_NBR,
	FRONT_OVERHANG,
	READ_OVERHANG,
	FILLER)
SELECT 	'LR',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	''
	

--Each transmission must contain a shipper record.
INSERT INTO  #ShipperRecord(
	RECORD_ID,
	SHIPPER_NAME,
	SHIPPER_PHONE,
	SHIPPER_ADDRESS,
	SHIPPER_CITY_STATE,
	FILLER)
SELECT 	'SR',
	'',
	'',
	'',
	'',
	''


--Each transmission must contain a receiver record.
INSERT INTO  #ReceiverRecord(
	RECORD_ID,
	RECEIVER_NAME,
	RECEIVER_PHONE,
	RECEIVER_ADDRESS,
	RECEIVER_CITY_STATE,
	FILLER)
SELECT 	'RR',
	'',
	'',
	'',
	'',
	''

--Each transmission must contain an equipment record.
INSERT INTO  #EquipmentRecord(
	RECORD_ID,
	TRACTOR_NBR,
	TRACTOR_YEAR,
	TRACTOR_MAKE,
	TRACTOR_LICENSE_NBR,
	TRACTOR_LICENSE_ST,
	TRACTOR_SERIAL_NBR,
	TRACTOR_WEIGHT,
	TRACTOR_AXLES,
	TRAILER_NBR,
	TRAILER_YEAR,
	TRAILER_MAKE,
	TRAILER_LICENSE_NBR,
	TRAILER_LICENSE_ST,
	TRAILER_SERIAL_NBR,
	TRAILER_WEIGHT,
	TRAILER_AXLES,
	OTHER_NBR,
	OTHER_YEAR,
	OTHER_MAKE,
	OTHER_LICENSE_NBR,
	OTHER_LICENSE_ST,
	OTHER_SERIAL_NBR,
	OTHER_WEIGHT,
	OTHER_AXLES,
	FILLER)
SELECT 	'ER',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	''

--Each transmission must contain an axle record.
INSERT INTO  #AxleRecord(
	RECORD_ID,
	NBR_OF_TIRES_1,
	NBR_OF_TIRES_2,
	NBR_OF_TIRES_3,
	NBR_OF_TIRES_4,
	NBR_OF_TIRES_5,
	NBR_OF_TIRES_6,
	NBR_OF_TIRES_7,
	NBR_OF_TIRES_8,
	NBR_OF_TIRES_9,
	NBR_OF_TIRES_10,
	NBR_OF_TIRES_11,
	NBR_OF_TIRES_12,
	TIRE_SIZE_1,
	TIRE_SIZE_2,
	TIRE_SIZE_3,
	TIRE_SIZE_4,
	TIRE_SIZE_5,
	TIRE_SIZE_6,
	TIRE_SIZE_7,
	TIRE_SIZE_8,
	TIRE_SIZE_9,
	TIRE_SIZE_10,
	TIRE_SIZE_11,
	TIRE_SIZE_12,
	AXLE_SPACING_1,
	AXLE_SPACING_2,
	AXLE_SPACING_3,
	AXLE_SPACING_4,
	AXLE_SPACING_5,
	AXLE_SPACING_6,
	AXLE_SPACING_7,
	AXLE_SPACING_8,
	AXLE_SPACING_9,
	AXLE_SPACING_10,
	AXLE_SPACING_11,
	AXLE_WEIGHT_1,
	AXLE_WEIGHT_2,
	AXLE_WEIGHT_3,
	AXLE_WEIGHT_4,
	AXLE_WEIGHT_5,
	AXLE_WEIGHT_6,
	AXLE_WEIGHT_7,
	AXLE_WEIGHT_8,
	AXLE_WEIGHT_9,
	AXLE_WEIGHT_10,
	AXLE_WEIGHT_11,
	AXLE_WEIGHT_12,
	FILLER)
SELECT 	'AR',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	''

--Each transmission may contain from one to thirty permit records. 
INSERT INTO  #PermitRecord(
	RECORD_ID,
	PERMIT_TYPE,
	ACTION_CODE,
	DESTINATION_FAX,
	EFFECTIVE_DATE,
	ACTUAL_GROSS_WT,
	AXLE_WEIGHT_1,
	AXLE_WEIGHT_2,
	AXLE_WEIGHT_3,
	AXLE_WEIGHT_4,
	AXLE_WEIGHT_5,
	AXLE_WEIGHT_6,
	AXLE_WEIGHT_7,
	AXLE_WEIGHT_8,
	AXLE_WEIGHT_9,
	AXLE_WEIGHT_10,
	AXLE_WEIGHT_11,
	AXLE_WEIGHT_12,
	REMARKS,
	ROUTES_LINE_1,
	ROUTES_LINE_2,
	ROUTES_LINE_3,
	COMMENTS_1,
	COMMENTS_2,
	ACCOUNT_NUMBER,
	FILLER)
SELECT 	'PR',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	''



--Now format the output result set 

INSERT INTO #foroutput
SELECT 	Left(LTrim(isNull(RECORD_ID, '')) + Space(2), 2) +
	Left(LTrim(isNull(CUSTOMER_NBR, '')) + Space(6), 6) +
	Left(LTrim(isNull(LOG_NBR, '')) + Space(5), 5) +
	Left(LTrim(isNull(REFERENCE_NBR_1, '')) + Space(10), 10) +
	Left(LTrim(isNull(REFERENCE_NBR_2, '')) + Space(20), 20) +
	Left(LTrim(isNull(DRIVER_NAME, '')) + Space(45), 45) +
	Left(LTrim(isNull(CONTACT_NAME, '')) + Space(15), 15) +
	Left(LTrim(isNull(CONTACT_PHONE, '')) + Space(10), 10) +
	Left(LTrim(isNull(EXTENSION, '')) + Space(6), 6) +
	Left(LTrim(isNull(EMAIL_ADDRESS, '')) + Space(60), 60) +
	Left(LTrim(isNull(CARRIER_NAME, '')) + Space(45), 45) +
	Left(LTrim(isNull(CARRIER_ADDRESS, '')) + Space(45), 45) +
	Left(LTrim(isNull(CARRIER_CITY, '')) + Space(20), 20) +
	Left(LTrim(isNull(CARRIER_ZIP, '')) + Space(10), 10) +
	Left(LTrim(isNull(FILLER, '')) + Space(200), 200) + @RecordTerminator
FROM #HeaderRecord

INSERT INTO #foroutput
SELECT 	Left(LTrim(isNull(RECORD_ID, '')) + Space(2), 2) +
	Left(LTrim(isNull(LOAD_DESCRIPTION, '')) + Space(45), 45) +
	Left(LTrim(isNull(LOAD_SERIAL_NBR, '')) + Space(21), 21) +
	Left(LTrim(isNull(LOAD_WEIGHT, '')) + Space(6), 6) +
	Left(LTrim(isNull(LOAD_WIDTH, '')) + Space(6), 6) +
	Left(LTrim(isNull(LOAD_LENGTH, '')) + Space(6), 6) +
	Left(LTrim(isNull(LOAD_HEIGHT, '')) + Space(6), 6) +
	Left(LTrim(isNull(OVER_ALL_WIDTH, '')) + Space(6), 6) +
	Left(LTrim(isNull(OVER_ALL_LENGTH, '')) + Space(6), 6) +
	Left(LTrim(isNull(OVER_ALL_HEIGHT, '')) + Space(6), 6) +
	Left(LTrim(isNull(ACT_GROSS_WEIGHT, '')) + Space(6), 6) +
	Left(LTrim(isNull(NBR_OF_PIECES, '')) + Space(2), 2) +
	Left(LTrim(isNull(LOAD_MAKE, '')) + Space(20), 20) +
	Left(LTrim(isNull(LOAD_MODEL_NBR, '')) + Space(10), 10) +
	Left(LTrim(isNull(FRONT_OVERHANG, '')) + Space(6), 6) +
	Left(LTrim(isNull(READ_OVERHANG, '')) + Space(6), 6) +
	Left(LTrim(isNull(FILLER, '')) + Space(339), 339) + @RecordTerminator
FROM #LoadRecord

INSERT INTO #foroutput
SELECT 	Left(LTrim(isNull(RECORD_ID, '')) + Space(2), 2) +
	Left(LTrim(isNull(SHIPPER_NAME, '')) + Space(45), 45) +
	Left(LTrim(isNull(SHIPPER_PHONE, '')) + Space(45), 45) +
	Left(LTrim(isNull(SHIPPER_ADDRESS, '')) + Space(45), 45) +
	Left(LTrim(isNull(SHIPPER_CITY_STATE, '')) + Space(45), 45) +
	Left(LTrim(isNull(FILLER, '')) + Space(317), 317) + @RecordTerminator
FROM #ShipperRecord

INSERT INTO #foroutput
SELECT 	Left(LTrim(isNull(RECORD_ID, '')) + Space(2), 2) +
	Left(LTrim(isNull(RECEIVER_NAME, '')) + Space(45), 45) +
	Left(LTrim(isNull(RECEIVER_PHONE, '')) + Space(45), 45) +
	Left(LTrim(isNull(RECEIVER_ADDRESS, '')) + Space(45), 45) +
	Left(LTrim(isNull(RECEIVER_CITY_STATE, '')) + Space(45), 45) +
	Left(LTrim(isNull(FILLER, '')) + Space(317), 317) + @RecordTerminator
FROM #ReceiverRecord

INSERT INTO #foroutput
SELECT 	Left(LTrim(isNull(RECORD_ID, '')) + Space(2), 2) +
	Left(LTrim(isNull(TRACTOR_NBR, '')) + Space(8), 8) +
	Left(LTrim(isNull(TRACTOR_YEAR, '')) + Space(2), 2) +
	Left(LTrim(isNull(TRACTOR_MAKE, '')) + Space(8), 8) +
	Left(LTrim(isNull(TRACTOR_LICENSE_NBR, '')) + Space(8), 8) +
	Left(LTrim(isNull(TRACTOR_LICENSE_ST, '')) + Space(2), 2) +
	Left(LTrim(isNull(TRACTOR_SERIAL_NBR, '')) + Space(21), 21) +
	Left(LTrim(isNull(TRACTOR_WEIGHT, '')) + Space(6), 6) +
	Left(LTrim(isNull(TRACTOR_AXLES, '')) + Space(2), 2) +
	Left(LTrim(isNull(TRAILER_NBR, '')) + Space(8), 8) +
	Left(LTrim(isNull(TRAILER_YEAR, '')) + Space(2), 2) +
	Left(LTrim(isNull(TRAILER_MAKE, '')) + Space(8), 8) +
	Left(LTrim(isNull(TRAILER_LICENSE_NBR, '')) + Space(8), 8) +
	Left(LTrim(isNull(TRAILER_LICENSE_ST, '')) + Space(2), 2) +
	Left(LTrim(isNull(TRAILER_SERIAL_NBR, '')) + Space(21), 21) +
	Left(LTrim(isNull(TRAILER_WEIGHT, '')) + Space(6), 6) +
	Left(LTrim(isNull(TRAILER_AXLES, '')) + Space(2), 2) +
	Left(LTrim(isNull(OTHER_NBR, '')) + Space(8), 8) +
	Left(LTrim(isNull(OTHER_YEAR, '')) + Space(2), 2) +
	Left(LTrim(isNull(OTHER_MAKE, '')) + Space(8), 8) +
	Left(LTrim(isNull(OTHER_LICENSE_NBR, '')) + Space(8), 8) +
	Left(LTrim(isNull(OTHER_LICENSE_ST, '')) + Space(2), 2) +
	Left(LTrim(isNull(OTHER_SERIAL_NBR, '')) + Space(21), 21) +
	Left(LTrim(isNull(OTHER_WEIGHT, '')) + Space(6), 6) +
	Left(LTrim(isNull(OTHER_AXLES, '')) + Space(2), 2) +
	Left(LTrim(isNull(FILLER, '')) + Space(326), 326) + @RecordTerminator
FROM #EquipmentRecord

INSERT INTO #foroutput
SELECT 	Left(LTrim(isNull(RECORD_ID, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_1, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_2, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_3, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_4, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_5, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_6, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_7, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_8, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_9, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_10, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_11, '')) + Space(2), 2) +
	Left(LTrim(isNull(NBR_OF_TIRES_12, '')) + Space(2), 2) +
	Left(LTrim(isNull(TIRE_SIZE_1, '')) + Space(10), 10) +
	Left(LTrim(isNull(TIRE_SIZE_2, '')) + Space(10), 10) +
	Left(LTrim(isNull(TIRE_SIZE_3, '')) + Space(10), 10) +
	Left(LTrim(isNull(TIRE_SIZE_4, '')) + Space(10), 10) +
	Left(LTrim(isNull(TIRE_SIZE_5, '')) + Space(10), 10) +
	Left(LTrim(isNull(TIRE_SIZE_6, '')) + Space(10), 10) +
	Left(LTrim(isNull(TIRE_SIZE_7, '')) + Space(10), 10) +
	Left(LTrim(isNull(TIRE_SIZE_8, '')) + Space(10), 10) +
	Left(LTrim(isNull(TIRE_SIZE_9, '')) + Space(10), 10) +
	Left(LTrim(isNull(TIRE_SIZE_10, '')) + Space(10), 10) +
	Left(LTrim(isNull(TIRE_SIZE_11, '')) + Space(10), 10) +
	Left(LTrim(isNull(TIRE_SIZE_12, '')) + Space(10), 10) +
	Left(LTrim(isNull(AXLE_SPACING_1, '')) + Space(5), 5) +
	Left(LTrim(isNull(AXLE_SPACING_2, '')) + Space(5), 5) +
	Left(LTrim(isNull(AXLE_SPACING_3, '')) + Space(5), 5) +
	Left(LTrim(isNull(AXLE_SPACING_4, '')) + Space(5), 5) +
	Left(LTrim(isNull(AXLE_SPACING_5, '')) + Space(5), 5) +
	Left(LTrim(isNull(AXLE_SPACING_6, '')) + Space(5), 5) +
	Left(LTrim(isNull(AXLE_SPACING_7, '')) + Space(5), 5) +
	Left(LTrim(isNull(AXLE_SPACING_8, '')) + Space(5), 5) +
	Left(LTrim(isNull(AXLE_SPACING_9, '')) + Space(5), 5) +
	Left(LTrim(isNull(AXLE_SPACING_10, '')) + Space(5), 5) +
	Left(LTrim(isNull(AXLE_SPACING_11, '')) + Space(5), 5) +
	Left(LTrim(isNull(AXLE_WEIGHT_1, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_2, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_3, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_4, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_5, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_6, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_7, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_8, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_9, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_10, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_11, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_12, '')) + Space(6), 6) +
	Left(LTrim(isNull(FILLER, '')) + Space(226), 226) + @RecordTerminator
FROM #AxleRecord

INSERT INTO #foroutput
SELECT 	Left(LTrim(isNull(RECORD_ID, '')) + Space(2), 2) +
	Left(LTrim(isNull(PERMIT_TYPE, '')) + Space(5), 5) +
	Left(LTrim(isNull(ACTION_CODE, '')) + Space(1), 1) +
	Left(LTrim(isNull(DESTINATION_FAX, '')) + Space(10), 10) +
	Left(LTrim(isNull(EFFECTIVE_DATE, '')) + Space(6), 6) +
	Left(LTrim(isNull(ACTUAL_GROSS_WT, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_1, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_2, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_3, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_4, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_5, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_6, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_7, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_8, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_9, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_10, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_11, '')) + Space(6), 6) +
	Left(LTrim(isNull(AXLE_WEIGHT_12, '')) + Space(6), 6) +
	Left(LTrim(isNull(REMARKS, '')) + Space(45), 45) +
	Left(LTrim(isNull(ROUTES_LINE_1, '')) + Space(45), 45) +
	Left(LTrim(isNull(ROUTES_LINE_2, '')) + Space(45), 45) +
	Left(LTrim(isNull(ROUTES_LINE_3, '')) + Space(45), 45) +
	Left(LTrim(isNull(COMMENTS_1, '')) + Space(45), 45) +
	Left(LTrim(isNull(COMMENTS_2, '')) + Space(45), 45) +
	Left(LTrim(isNull(ACCOUNT_NUMBER, '')) + Space(20), 20) +
	Left(LTrim(isNull(FILLER, '')) + Space(107), 107) + @RecordTerminator
FROM #PermitRecord
*/

--Final output resultset
select cast(recbuf as text) from #foroutput


GO
GRANT EXECUTE ON  [dbo].[permit_comdata_export_sp] TO [public]
GO

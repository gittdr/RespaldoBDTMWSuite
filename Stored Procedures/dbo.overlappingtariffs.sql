SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/* Provides a list of tariffs which overlap the tariff index being saved.  Based on displayed fields of the tariff index datawindows.

Created 1/18/02 dpete pts 12839 for Gibson Petroleum
* 11/19/2007 PTS 38811 JDS:  mod 4 cols from INT  to Dec(19,4) 
* 4/18/08 40260 recode Pauls DPETE remove index hints
* 46113 pmill added trk_mincarriersvcdays and max_carriersvcservicedays

*/

	
CREATE PROCEDURE [dbo].[overlappingtariffs]
(@ckforoverlappingrates varchar(20), @keysusedinmatching varchar(15),
@TariffID varchar(12), @tariffitem varchar(12),
@trknumber int,
@trk_primary char (1),
@cmp_mastercompany varchar(8),
@trk_billto varchar(8),
@trk_orderedby varchar(8),
@cmp_othertype1 varchar(6),
@cmp_othertype2 varchar(6),
@cmd_code char(8) ,
@cmd_class char(8) ,
@trk_carrier varchar(8) ,
@trk_boardcarrier char(6),
@trk_load char(6) ,
@trk_team char(6) ,
@trk_startdate datetime,
@trk_enddate datetime,
@trk_revtype1 varchar(6),
@trk_revtype2 varchar(6) ,
@trk_revtype3 varchar(6),
@trk_revtype4 varchar(6),
@trk_company varchar(8) ,
@trk_lghtype1 char(6) ,
@trk_terms char(6) ,
@trl_type1 varchar(6) ,
@trl_type2 varchar(6) ,
@trl_type3 varchar(6),
@trl_type4 varchar(6) ,
@trk_originpoint char(8),
@trk_origincity int ,
@trk_originstate varchar(6),
@trk_originzip char(10),
@trk_origincounty char(3) ,
@trk_destpoint char(8),
@trk_destcity int,
@trk_deststate varchar(6),
@trk_destzip char(10),
@trk_destcounty char(3) ,
@trk_triptype_or_region char(1) ,
@trk_tt_or_oregion varchar(10) ,
@trk_dregion varchar(10) ,
@mpp_type1 varchar(6),
@mpp_type2 varchar(6) ,
@mpp_type3 varchar(6) ,
@mpp_type4 varchar(6) ,
@trc_type1 varchar(6) ,
@trc_type2 varchar(6) ,
@trc_type3 varchar(6) ,
@trc_type4 varchar(6) ,
@trk_stoptype varchar(6),
@trk_delays varchar(6),
@trk_ooamileage int ,
@trk_ooastop int ,
@trk_carryins1 int ,
@trk_carryins2 int ,
@trk_minstops int ,
@trk_maxstops int ,
@trk_minweight decimal(19,4), 		-- PTS 38811	
@trk_maxweight decimal(19,4),		-- PTS 38811	
--@trk_minweight int,
--@trk_maxweight int,
@trk_wgtunit varchar(6),
@trk_minpieces int ,
@trk_maxpieces int,
@trk_countunit varchar(6),
@trk_minvolume decimal(19,4),		-- PTS 38811	
@trk_maxvolume decimal(19,4),		-- PTS 38811	
--@trk_minvolume int,
--@trk_maxvolume int,
@trk_volunit varchar(6),
@trk_minmiles int ,
@trk_maxmiles int,
@trk_distunit varchar(6) ,
@trk_minodmiles int ,
@trk_maxodmiles int ,
@trk_odunit varchar(6),
@trk_minvariance money,
@trk_maxvariance money,
@trk_custdoc int,
@trk_billtoregion varchar(10),
@trk_mincarriersvcdays int,		--46113 pmill
@trk_maxcarriersvcdays int )	--46113 pmill
AS
Create table #duprates (
tar_number int null,
tar_tariffnumber varchar(12) null,
tar_tariffitem varchar(12) null,
trk_number int,
trk_description varchar(50) null,
trk_indexseq int null,
trk_startdate datetime null,
trk_enddate datetime null
)
Declare @matcostate varchar(6), @matchdstate varchar(6)

Select @ckforoverlappingrates = Left(IsNUll(@ckforoverlappingrates,'N'),1),
		@TariffID = RTRIM(@TariffID),
		@trknumber = IsNull(@trknumber,0),
		 @trk_triptype_or_region = IsNUll(@trk_triptype_or_region,'X'),
		@trk_tt_or_oregion = IsNull(@trk_tt_or_oregion,''),
		@trk_dregion = ISNULL(@trk_dregion,''),
		@cmp_mastercompany = IsNull(@cmp_mastercompany,'UNKNOWN'),
		@mpp_type1 = IsNull(@mpp_type1 ,'UNK'),
		@mpp_type2 = IsNull(@mpp_type2,'UNK'),
		 @mpp_type3 = IsnULL(@mpp_type3,'UNK'),
		@mpp_type4 = IsNull(@mpp_type4,'UNK'),
		@trc_type1 = IsNull(@trc_type1,'UNK'),
		@trc_type2 = IsNull(@trc_type2,'UNK'),
		 @trc_type3 = IsNull(@trc_type3,'UNK'),
		@trc_type4 = IsNull(@trc_type4,'UNK'),
		@trk_stoptype = IsNull(@trk_stoptype,'UNK'),
		@trk_delays = IsNull(@trk_delays,'UNK'),
		@trk_ooamileage = IsNull(@trk_ooamileage,0),
		@trk_ooastop = IsNull(@trk_ooastop,0),
		@trk_carryins1 = IsNull(@trk_carryins1,0),
		@trk_carryins2 = IsNull(@trk_carryins2,0),
		@trk_wgtunit = IsNull(@trk_wgtunit,'LBS'),
		@trk_countunit = isNull(@trk_countunit,'PCS'),
		@trk_volunit = IsNull(@trk_volunit,'GAL'),
		@trk_distunit = IsNull(@trk_distunit ,'MIL'),
		@trk_odunit = IsNull(@trk_odunit ,'MIL'),
		@trk_terms = IsNull(@trk_terms,'UNK'),
		@trk_originstate = RTRIM(@trk_originstate),
		@trk_deststate = RTRIM(@trk_deststate),
                @trk_custdoc = ISNULL(@trk_custdoc, 0), 
                @trk_billtoregion = ISNULL(@trk_billtoregion, '')

If Left(@ckforoverlappingrates,1) <> 'N'
  BEGIN
	If UPPER(ISNULL(@keysusedinmatching,'NONE')) = 'NONE'
		Insert Into #duprates
		Select trk.tar_number,
		tar_tarriffnumber,
		tar_tariffitem,
		trk_number,
		trk_description,
		IsNull(trk_IndexSeq,0),
		trk_startdate,
		trk_enddate
		From tariffkey trk, tariffheader tar
		Where trk_number <> @trknumber 
		and NOT( (@trk_enddate < trk_startdate) or (@trk_startdate > trk_enddate)) AND
		 @trk_primary = trk_primary
		and @cmp_mastercompany = IsNull(cmp_mastercompany,'UNKNOWN')
		And @trk_billto = trk_billto
		and @trk_orderedby = trk_orderedby
		and @cmp_othertype1 = cmp_othertype1
		and @cmp_othertype2 = cmp_othertype2
		AND @cmd_code = cmd_code
		AND @cmd_class = cmd_class
		and @trk_carrier = trk_carrier
		and @trk_boardcarrier = trk_boardcarrier
		and @trk_load = trk_load
		and @trk_team = trk_team 
		and @trk_revtype1 = trk_revtype1
		and @trk_revtype2 = trk_revtype2
		and @trk_revtype3 = trk_revtype3
		and @trk_revtype4 = trk_revtype4
		and @trk_company = trk_company 
		and @trk_lghtype1 = trk_lghtype1
		and @trk_terms = IsNull(trk_terms,'UNK')
		and @trl_type1 = trl_type1
		and @trl_type2 = trl_type2 
		and @trl_type3 = trl_type3
		and @trl_type4 = trl_type4
		and @trk_originpoint = trk_originpoint
		and @trk_origincity = trk_origincity
		and @trk_originstate = Rtrim(convert(varchar(6),isnull(trk_originstate,'XX')))
		and @trk_originzip = trk_originzip
		and @trk_origincounty = trk_origincounty
		and @trk_destpoint = trk_destpoint
		and @trk_destcity =  trk_destcity
		and @trk_destzip = trk_destzip
		and @trk_deststate = Rtrim(convert(varchar(6),ISNULL(trk_deststate,'XX')))
		and @trk_destcounty = trk_destcounty
		and @trk_triptype_or_region = IsNUll(trk_triptype_or_region,'X')
		and @trk_tt_or_oregion = IsNull(trk_tt_or_oregion,'')
		and @trk_dregion = ISNULL(trk_dregion,'')
		and @mpp_type1 = IsNull(mpp_type1 ,'UNK')
		and @mpp_type2 = IsNull(mpp_type2,'UNK')
		and @mpp_type3 = IsnULL(mpp_type3,'UNK')
		and @mpp_type4 = IsNull(mpp_type4,'UNK')
		and @trc_type1 = IsNull(trc_type1,'UNK')
		and @trc_type2 = IsNull(trc_type2,'UNK')
		and @trc_type3 = IsNull(trc_type3,'UNK')
		and @trc_type4 = IsNull(trc_type4,'UNK')
		and @trk_stoptype = IsNull(trk_stoptype,'UNK')
		and @trk_delays = IsNull(trk_delays,'UNK')
		and @trk_ooamileage = IsNull(trk_ooamileage,0)
		and @trk_ooastop = IsNull(trk_ooastop,0)
		and @trk_carryins1 = IsNull(trk_carryins1,0)
		and @trk_carryins2 = IsNull(trk_carryins2,0)
		and @trk_minstops = trk_minstops
		and @trk_maxstops = trk_maxstops
		and @trk_minweight = trk_minweight
		and @trk_maxweight = trk_maxweight
		and @trk_wgtunit =  IsNull(trk_wgtunit,'LBS')
		and @trk_minpieces = trk_minpieces
		and @trk_maxpieces = trk_maxpieces
		and @trk_countunit = isNull(trk_countunit,'PCS')
		and @trk_minvolume = trk_minvolume
		and @trk_maxvolume = trk_maxvolume
		and @trk_volunit = IsNull(trk_volunit,'GAL')
		and @trk_minmiles = trk_minmiles
		and @trk_maxmiles = trk_maxmiles 
		and @trk_distunit = IsNull(trk_distunit ,'MIL')
		and @trk_minodmiles = trk_minodmiles
		and @trk_maxodmiles = trk_maxodmiles
		and @trk_odunit = IsNull(trk_odunit ,'MIL')
		and @trk_minvariance = trk_minvariance
		and @trk_maxvariance = trk_maxvariance
		and @trk_mincarriersvcdays = trk_mincarriersvcdays	--46113 pmill
		and @trk_maxcarriersvcdays = trk_maxcarriersvcdays	--46113 pmill
		and tar.tar_number = trk.tar_number 
                and ISNULL(trk_custdoc, 0) = @trk_custdoc 
                and ISNULL(trk_billtoregion, '') = @trk_billtoregion

	If UPPER(ISNULL(@keysusedinmatching,'NONE')) = 'ID'
		Insert Into #duprates
		Select trk.tar_number,
		tar_tarriffnumber,
		tar_tariffitem,
		trk_number,
		trk_description,
		IsNull(trk_IndexSeq,0),
		trk_startdate,
		trk_enddate
		From tariffheader tar ,tariffkey trk 
		Where tar.tar_tarriffnumber = @TariffID
		and tar.tar_number = trk.tar_number
		and trk.trk_number <> @trknumber
		and NOT( (@trk_enddate < trk_startdate) or (@trk_startdate > trk_enddate))
		and @trk_primary = trk_primary
		and @cmp_mastercompany = IsNull(cmp_mastercompany,'UNKNOWN')
		And @trk_billto = trk_billto
		and @trk_orderedby = trk_orderedby
		and @cmp_othertype1 = cmp_othertype1
		and @cmp_othertype2 = cmp_othertype2
		AND @cmd_code = cmd_code
		AND @cmd_class = cmd_class
		and @trk_carrier = trk_carrier
		and @trk_boardcarrier = trk_boardcarrier
		and @trk_load = trk_load
		and @trk_team = trk_team 
		and @trk_revtype1 = trk_revtype1
		and @trk_revtype2 = trk_revtype2
		and @trk_revtype3 = trk_revtype3
		and @trk_revtype4 = trk_revtype4
		and @trk_company = trk_company 
		and @trk_lghtype1 = trk_lghtype1
		and @trk_terms = IsNull(trk_terms,'UNK')
		and @trl_type1 = trl_type1
		and @trl_type2 = trl_type2 
		and @trl_type3 = trl_type3
		and @trl_type4 = trl_type4
		and @trk_originpoint = trk_originpoint
		and @trk_origincity = trk_origincity
		and @trk_originstate = Rtrim(convert(varchar(6),isnull(trk_originstate,'XX')))
		and @trk_originzip = trk_originzip
		and @trk_origincounty = trk_origincounty
		and @trk_destpoint = trk_destpoint
		and @trk_destcity =  trk_destcity
		and @trk_destzip = trk_destzip
		and @trk_deststate = Rtrim(convert(varchar(6),ISNULL(trk_deststate,'XX')))
		and @trk_destcounty = trk_destcounty
		and @trk_triptype_or_region = IsNUll(trk_triptype_or_region,'X')
		and @trk_tt_or_oregion = IsNull(trk_tt_or_oregion,'')
		and @trk_dregion = ISNULL(trk_dregion,'')
		and @mpp_type1 = IsNull(mpp_type1 ,'UNK')
		and @mpp_type2 = IsNull(mpp_type2,'UNK')
		and @mpp_type3 = IsnULL(mpp_type3,'UNK')
		and @mpp_type4 = IsNull(mpp_type4,'UNK')
		and @trc_type1 = IsNull(trc_type1,'UNK')
		and @trc_type2 = IsNull(trc_type2,'UNK')
		and @trc_type3 = IsNull(trc_type3,'UNK')
		and @trc_type4 = IsNull(trc_type4,'UNK')
		and @trk_stoptype = IsNull(trk_stoptype,'UNK')
		and @trk_delays = IsNull(trk_delays,'UNK')
		and @trk_ooamileage = IsNull(trk_ooamileage,0)
		and @trk_ooastop = IsNull(trk_ooastop,0)
		and @trk_carryins1 = IsNull(trk_carryins1,0)
		and @trk_carryins2 = IsNull(trk_carryins2,0)
		and @trk_minstops = trk_minstops
		and @trk_maxstops = trk_maxstops
		and @trk_minweight = trk_minweight
		and @trk_maxweight = trk_maxweight
		and @trk_wgtunit =  IsNull(trk_wgtunit,'LBS')
		and @trk_minpieces = trk_minpieces
		and @trk_maxpieces = trk_maxpieces
		and @trk_countunit = isNull(trk_countunit,'PCS')
		and @trk_minvolume = trk_minvolume
		and @trk_maxvolume = trk_maxvolume
		and @trk_volunit = IsNull(trk_volunit,'GAL')
		and @trk_minmiles = trk_minmiles
		and @trk_maxmiles = trk_maxmiles 
		and @trk_distunit = IsNull(trk_distunit ,'MIL')
		and @trk_minodmiles = trk_minodmiles
		and @trk_maxodmiles = trk_maxodmiles
		and @trk_odunit = IsNull(trk_odunit ,'MIL')
		and @trk_minvariance = trk_minvariance
		and @trk_maxvariance = trk_maxvariance
		and @trk_mincarriersvcdays = trk_mincarriersvcdays	--46113 pmill
		and @trk_maxcarriersvcdays = trk_maxcarriersvcdays	--46113 pmill
                and ISNULL(trk_custdoc, 0) = @trk_custdoc 
                and ISNULL(trk_billtoregion, '') = @trk_billtoregion
		
		
	If UPPER(ISNULL(@keysusedinmatching,'NONE')) = 'ITEM'
		Insert Into #duprates
		Select trk.tar_number,
		tar_tarriffnumber,
		tar_tariffitem,
		trk_number,
		trk_description,
		IsNull(trk_IndexSeq,0),
		trk_startdate,
		trk_enddate
		--From tariffheader tar with(index=dk_tar_tarriffnumber) ,tariffkey trk 
      From tariffheader tar  ,tariffkey trk 
		Where tar.tar_tariffitem = @TariffItem
		and tar.tar_number = trk.tar_number
		and trk.trk_number <> @trknumber
		and NOT( (@trk_enddate < trk_startdate) or (@trk_startdate > trk_enddate))
		and @trk_primary = trk_primary
		and @cmp_mastercompany = IsNull(cmp_mastercompany,'UNKNOWN')
		And @trk_billto = trk_billto
		and @trk_orderedby = trk_orderedby
		and @cmp_othertype1 = cmp_othertype1
		and @cmp_othertype2 = cmp_othertype2
		AND @cmd_code = cmd_code
		AND @cmd_class = cmd_class
		and @trk_carrier = trk_carrier
		and @trk_boardcarrier = trk_boardcarrier
		and @trk_load = trk_load
		and @trk_team = trk_team 
		and @trk_revtype1 = trk_revtype1
		and @trk_revtype2 = trk_revtype2
		and @trk_revtype3 = trk_revtype3
		and @trk_revtype4 = trk_revtype4
		and @trk_company = trk_company 
		and @trk_lghtype1 = trk_lghtype1
		and @trk_terms = IsNull(trk_terms,'UNK')
		and @trl_type1 = trl_type1
		and @trl_type2 = trl_type2 
		and @trl_type3 = trl_type3
		and @trl_type4 = trl_type4
		and @trk_originpoint = trk_originpoint
		and @trk_origincity = trk_origincity
		and @trk_originstate = Rtrim(convert(varchar(6),isnull(trk_originstate,'XX')))
		and @trk_originzip = trk_originzip
		and @trk_origincounty = trk_origincounty
		and @trk_destpoint = trk_destpoint
		and @trk_destcity =  trk_destcity
		and @trk_destzip = trk_destzip
		and @trk_deststate = Rtrim(convert(varchar(6),ISNULL(trk_deststate,'XX')))
		and @trk_destcounty = trk_destcounty
		and @trk_triptype_or_region = IsNUll(trk_triptype_or_region,'X')
		and @trk_tt_or_oregion = IsNull(trk_tt_or_oregion,'')
		and @trk_dregion = ISNULL(trk_dregion,'')
		and @mpp_type1 = IsNull(mpp_type1 ,'UNK')
		and @mpp_type2 = IsNull(mpp_type2,'UNK')
		and @mpp_type3 = IsnULL(mpp_type3,'UNK')
		and @mpp_type4 = IsNull(mpp_type4,'UNK')
		and @trc_type1 = IsNull(trc_type1,'UNK')
		and @trc_type2 = IsNull(trc_type2,'UNK')
		and @trc_type3 = IsNull(trc_type3,'UNK')
		and @trc_type4 = IsNull(trc_type4,'UNK')
		and @trk_stoptype = IsNull(trk_stoptype,'UNK')
		and @trk_delays = IsNull(trk_delays,'UNK')
		and @trk_ooamileage = IsNull(trk_ooamileage,0)
		and @trk_ooastop = IsNull(trk_ooastop,0)
		and @trk_carryins1 = IsNull(trk_carryins1,0)
		and @trk_carryins2 = IsNull(trk_carryins2,0)
		and @trk_minstops = trk_minstops
		and @trk_maxstops = trk_maxstops
		and @trk_minweight = trk_minweight
		and @trk_maxweight = trk_maxweight
		and @trk_wgtunit =  IsNull(trk_wgtunit,'LBS')
		and @trk_minpieces = trk_minpieces
		and @trk_maxpieces = trk_maxpieces
		and @trk_countunit = isNull(trk_countunit,'PCS')
		and @trk_minvolume = trk_minvolume
		and @trk_maxvolume = trk_maxvolume
		and @trk_volunit = IsNull(trk_volunit,'GAL')
		and @trk_minmiles = trk_minmiles
		and @trk_maxmiles = trk_maxmiles 
		and @trk_distunit = IsNull(trk_distunit ,'MIL')
		and @trk_minodmiles = trk_minodmiles
		and @trk_maxodmiles = trk_maxodmiles
		and @trk_odunit = IsNull(trk_odunit ,'MIL')
		and @trk_minvariance = trk_minvariance
		and @trk_maxvariance = trk_maxvariance
		and @trk_mincarriersvcdays = trk_mincarriersvcdays	--46113 pmill
		and @trk_maxcarriersvcdays = trk_maxcarriersvcdays	--46113 pmill
                and ISNULL(trk_custdoc, 0) = @trk_custdoc 
                and ISNULL(trk_billtoregion, '') = @trk_billtoregion
		
		
	If UPPER(ISNULL(@keysusedinmatching,'NONE')) = 'BOTH'
		Insert Into #duprates
		Select trk.tar_number,
		tar_tarriffnumber,
		tar_tariffitem,
		trk_number,
		trk_description,
		IsNull(trk_IndexSeq,0),
		trk_startdate,
		trk_enddate
	--	From tariffheader tar with(index=dk_tar_tarriffnumber)  ,tariffkey trk 
        From tariffheader tar   ,tariffkey trk 
		Where tar.tar_tarriffnumber = @TariffID
		and tar.tar_tariffitem = @TariffItem
		and tar.tar_number = trk.tar_number
		and trk.trk_number <> @trknumber
	and NOT( (@trk_enddate < trk_startdate) or (@trk_startdate > trk_enddate))
		and @trk_primary = trk_primary
		and @cmp_mastercompany = IsNull(cmp_mastercompany,'UNKNOWN')
		And @trk_billto = trk_billto
		and @trk_orderedby = trk_orderedby
		and @cmp_othertype1 = cmp_othertype1
		and @cmp_othertype2 = cmp_othertype2
		AND @cmd_code = cmd_code
		AND @cmd_class = cmd_class
		and @trk_carrier = trk_carrier
		and @trk_boardcarrier = trk_boardcarrier
		and @trk_load = trk_load
		and @trk_team = trk_team 
		and @trk_revtype1 = trk_revtype1
		and @trk_revtype2 = trk_revtype2
		and @trk_revtype3 = trk_revtype3
		and @trk_revtype4 = trk_revtype4
		and @trk_company = trk_company 
		and @trk_lghtype1 = trk_lghtype1
		and @trk_terms = IsNull(trk_terms,'UNK')
		and @trl_type1 = trl_type1
		and @trl_type2 = trl_type2 
		and @trl_type3 = trl_type3
		and @trl_type4 = trl_type4
		and @trk_originpoint = trk_originpoint
		and @trk_origincity = trk_origincity
		and @trk_originstate = Rtrim(convert(varchar(6),isnull(trk_originstate,'XX')))
		and @trk_originzip = trk_originzip
		and @trk_origincounty = trk_origincounty
		and @trk_destpoint = trk_destpoint
		and @trk_destcity =  trk_destcity
		and @trk_destzip = trk_destzip
		and @trk_deststate = Rtrim(convert(varchar(6),ISNULL(trk_deststate,'XX')))
		and @trk_destcounty = trk_destcounty
		and @trk_triptype_or_region = IsNUll(trk_triptype_or_region,'X')
		and @trk_tt_or_oregion = IsNull(trk_tt_or_oregion,'')
		and @trk_dregion = ISNULL(trk_dregion,'')
		and @mpp_type1 = IsNull(mpp_type1 ,'UNK')
		and @mpp_type2 = IsNull(mpp_type2,'UNK')
		and @mpp_type3 = IsnULL(mpp_type3,'UNK')
		and @mpp_type4 = IsNull(mpp_type4,'UNK')
		and @trc_type1 = IsNull(trc_type1,'UNK')
		and @trc_type2 = IsNull(trc_type2,'UNK')
		and @trc_type3 = IsNull(trc_type3,'UNK')
		and @trc_type4 = IsNull(trc_type4,'UNK')
		and @trk_stoptype = IsNull(trk_stoptype,'UNK')
		and @trk_delays = IsNull(trk_delays,'UNK')
		and @trk_ooamileage = IsNull(trk_ooamileage,0)
		and @trk_ooastop = IsNull(trk_ooastop,0)
		and @trk_carryins1 = IsNull(trk_carryins1,0)
		and @trk_carryins2 = IsNull(trk_carryins2,0)
		and @trk_minstops = trk_minstops
		and @trk_maxstops = trk_maxstops
		and @trk_minweight = trk_minweight
		and @trk_maxweight = trk_maxweight
		and @trk_wgtunit =  IsNull(trk_wgtunit,'LBS')
		and @trk_minpieces = trk_minpieces
		and @trk_maxpieces = trk_maxpieces
		and @trk_countunit = isNull(trk_countunit,'PCS')
		and @trk_minvolume = trk_minvolume
		and @trk_maxvolume = trk_maxvolume
		and @trk_volunit = IsNull(trk_volunit,'GAL')
		and @trk_minmiles = trk_minmiles
		and @trk_maxmiles = trk_maxmiles 
		and @trk_distunit = IsNull(trk_distunit ,'MIL')
		and @trk_minodmiles = trk_minodmiles
		and @trk_maxodmiles = trk_maxodmiles
		and @trk_odunit = IsNull(trk_odunit ,'MIL')
		and @trk_minvariance = trk_minvariance
		and @trk_maxvariance = trk_maxvariance
		and @trk_mincarriersvcdays = trk_mincarriersvcdays	--46113 pmill
		and @trk_maxcarriersvcdays = trk_maxcarriersvcdays	--46113 pmill
                and ISNULL(trk_custdoc, 0) = @trk_custdoc 
                and ISNULL(trk_billtoregion, '') = @trk_billtoregion
		
		
END	
		
 Select tar_number,
		tar_tariffnumber,
		tar_tariffitem,
		trk_number,
		trk_description,
		trk_IndexSeq,
		trk_startdate,
		trk_enddate
From #duprates
Order by tar_number,trk_indexseq

Drop table #duprates





GO
GRANT EXECUTE ON  [dbo].[overlappingtariffs] TO [public]
GO

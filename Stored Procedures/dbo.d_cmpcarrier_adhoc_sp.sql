SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[d_cmpcarrier_adhoc_sp]
@cartype1 varchar (6), 
@cartype2 varchar (6), 
@cartype3 varchar (6), 
@cartype4 varchar (6), 
@liabilitylimit money, 
@cargolimit money, 
@servicerating varchar (6), 
@carid varchar (8), 
@carname varchar (64), 
@rateonly char (1), 
@origin varchar (58), 
@destination varchar (58), 
@insurance char (1), 
@w9 char (1), 
@contract char (1), 
@history char (1), 
@domicile int, 
@contact varchar (30), 
@trcaccess varchar (1000), 
@trlaccess varchar (1000), 
@drvqual varchar (1000), 
@carqual varchar (1000), 
@stp_departure_dt datetime, 
@oradius int, 
@dradius int, 
@returntariffs char (1), 
@branch varchar (12), 
@ratesonly char (1), 
@expdate int
as
/*
ARGS:
@rateonly - used in ACS filter, "Show Rate" on the front end.  This will include extra results for carriers with state to state rates setup. 

@ratesonly - Used in the Planning Wksht filter views and appear on both External Equipment and Co. Carrier tabs.  "Only Carriers with Rates On File:" on the front end.
	Excludes carriers from the Co. Carrier result set unless they have rates on file.

@expdate  - expdate ini setting to determine if an expiration is coming soon

*/
set nocount on;
set transaction isolation level read uncommitted

declare  @temp_filteredcarriers table
(
    fcr_carrier        varchar (8) primary key   ,
    fcr_car_city       int            ,
    fcr_omiles_dom     decimal (12, 6) null,
    fcr_dmiles_dom     decimal (12, 6) null,
    fcr_dom_lat        decimal (12, 6) null,
    fcr_dom_long       decimal (12, 6) null,
    fcr_domicile_state char (2)       ,
    fcr_origdomicile   char (1)       ,
    fcr_destdomicile   char (1)       ,
    keepfromfilter     char (1)       
);
declare  @origin_states table
(
    origin_state varchar (6)
);
declare  @destination_states table
(
    destination_state varchar (6)
);
create table #tariffdata
(
    tar_number     int          null,
    trk_carrier    varchar (8)  null,
    tar_rowbasis   varchar (6)  null,
    tar_colbasis   varchar (6)  null,
    trc_rowcolumn  char (1)     null,
    trc_matchvalue varchar (10) null,
    cty_code       int          null,
    cty_state      varchar (6)  null
);
declare  @temp1 table
(
    temp1_id                   int             identity,
    trk_number                 int             null,
    tar_number                 int             null,
    tar_rate                   decimal (9, 4)  null,
    trk_carrier                varchar (8)     null,
    Crh_Total                  int             null,
    Crh_OnTime                 int             null,
    cht_itemcode               varchar (6)     null,
    cht_description            varchar (30)    null,
    Crh_percent                int             null,
    Crh_AveFuel                money           null,
    Crh_AveTotal               money           null,
    Crh_AveAcc                 money           null,
    car_name                   varchar (64)    null,
    car_address1               varchar (64)    null,
    car_address2               varchar (64)    null,
    car_scac                   varchar (64)    null,
    car_phone1                 varchar (10)    null,
    car_phone2                 varchar (10)    null,
    car_contact                varchar (25)    null,
    car_phone3                 varchar (10)    null,
    car_email                  varchar (128)   null,
    car_currency               varchar (6)     null,
    cht_currunit               varchar (6)     null,
    car_rating                 varchar (25)    null,
    exp_priority1              int             null,
    exp_priority2              int             null,
    cty_nmstct                 varchar (30)    null,
    cartype1_t                 varchar (20)    null,
    cartype2_t                 varchar (20)    null,
    cartype3_t                 varchar (20)    null,
    cartype4_t                 varchar (20)    null,
    car_type1                  varchar (6)     null,
    car_type2                  varchar (6)     null,
    car_type3                  varchar (6)     null,
    car_type4                  varchar (6)     null,
    totalordersfiltered        int             null,
    ontimeordersfiltered       int             null,
    percentontimefiltered      int             null,
    keepfromfilter             char (1)        null,
    orig_domicile              char (1)        null,
    dest_domicile              char (1)        null,
    rateonfileorigin           char (1)        null,
    rateonfiledest             char (1)        null,
    haspaymenthist             char (1)        null,
    PayHistAtOrigin            char (1)        null,
    PayHistAtDest              char (1)        null,
    RatePaidAtOrigin           char (1)        null,
    RatePaidAtDest             char (1)        null,
    orig_domicile_comb         char (1)        null,
    dest_domicile_comb         char (1)        null,
    rateonfileorigin_comb      char (1)        null,
    rateonfiledest_comb        char (1)        null,
    haspaymenthist_comb        char (1)        null,
    PayHistAtOrigin_comb       char (1)        null,
    PayHistAtDest_comb         char (1)        null,
    RatePaidAtOrigin_comb      char (1)        null,
    RatePaidAtDest_comb        char (1)        null,
    MatchResult                varchar (1000)  null,
    CombinedMatchResult        varchar (1000)  null,
    test                       char (1)        null,
    totalordersfiltered_comb   int             null,
    ontimeordersfiltered_comb  int             null,
    percentontimefiltered_comb int             null,
    pri1expsoon                int             null,
    pri2expsoon                int             null,
    car_exp1date               datetime        null,
    car_exp2date               datetime        null,
    last_chd_id                int             null,
    last_used_date             datetime        null,
    last_billed                money           null,
    last_paid                  money           null,
    total_billed               money           null,
    pay_linehaul               money           null,
    pay_accessorial            money           null,
    pay_fsc                    money           null,
    cty_code                   int             null,
    cty_state                  varchar (6)     null,
    total_trips                int             null,
    total_late                 int             null,
    min_chd_id                 int             null,
    min_billed                 money           null,
    min_paid                   money           null,
    max_chd_id                 int             null,
    max_billed                 money           null,
    max_paid                   money           null,
    --PTS 49332 JJF 20091008
    distance_to_origin         int             null,
    distance_to_destination    int             null,
    --END PTS 49332 JJF 20091008
    /*Start PTS 57012 CGK*/
    min_margin_amount          money           null,
    min_margin_percent         decimal (13, 4) null,
    max_margin_amount          money           null,
    max_margin_percent         decimal (13, 4) null,
    /*Start PTS 57012 CGK*/
    preferred_lane             char (1)        null, --PTS52011 MBR 04/23/10
    --PTS 51918 JJF 20110209
    qualification_list_drv     varchar (255)   null,
    qualification_list_trc     varchar (255)   null,
    qualification_list_trl     varchar (255)   null
--END PTS 51918 JJF 20110209
);
--PTS 49964 JJF 20091221 sqlserver2008 workaround
declare  @temp2 table
(
    temp1_id                   int            identity,
    trk_number                 int            null,
    tar_number                 int            null,
    tar_rate                   decimal (9, 4) null,
    trk_carrier                varchar (8)    null,
    Crh_Total                  int            null,
    Crh_OnTime                 int            null,
    cht_itemcode               varchar (6)    null,
    cht_description            varchar (30)   null,
    Crh_percent                int            null,
    Crh_AveFuel                money          null,
    Crh_AveTotal               money          null,
    Crh_AveAcc                 money          null,
    car_name                   varchar (64)   null,
    car_address1               varchar (64)   null,
    car_address2               varchar (64)   null,
    car_scac                   varchar (64)   null,
    car_phone1                 varchar (10)   null,
    car_phone2                 varchar (10)   null,
    car_contact                varchar (25)   null,
    car_phone3                 varchar (10)   null,
    car_email                  varchar (128)  null,
    car_currency               varchar (6)    null,
    cht_currunit               varchar (6)    null,
    car_rating                 varchar (25)   null,
    exp_priority1              int            null,
    exp_priority2              int            null,
    cty_nmstct                 varchar (30)   null,
    cartype1_t                 varchar (20)   null,
    cartype2_t                 varchar (20)   null,
    cartype3_t                 varchar (20)   null,
    cartype4_t                 varchar (20)   null,
    car_type1                  varchar (6)    null,
    car_type2                  varchar (6)    null,
    car_type3                  varchar (6)    null,
    car_type4                  varchar (6)    null,
    totalordersfiltered        int            null,
    ontimeordersfiltered       int            null,
    percentontimefiltered      int            null,
    keepfromfilter             char (1)       null,
    orig_domicile              char (1)       null,
    dest_domicile              char (1)       null,
    rateonfileorigin           char (1)       null,
    rateonfiledest             char (1)       null,
    haspaymenthist             char (1)       null,
    PayHistAtOrigin            char (1)       null,
    PayHistAtDest              char (1)       null,
    RatePaidAtOrigin           char (1)       null,
    RatePaidAtDest             char (1)       null,
    orig_domicile_comb         char (1)       null,
    dest_domicile_comb         char (1)       null,
    rateonfileorigin_comb      char (1)       null,
    rateonfiledest_comb        char (1)       null,
    haspaymenthist_comb        char (1)       null,
    PayHistAtOrigin_comb       char (1)       null,
    PayHistAtDest_comb         char (1)       null,
    RatePaidAtOrigin_comb      char (1)       null,
    RatePaidAtDest_comb        char (1)       null,
    MatchResult                varchar (1000) null,
    CombinedMatchResult        varchar (1000) null,
    test                       char (1)       null,
    totalordersfiltered_comb   int            null,
    ontimeordersfiltered_comb  int            null,
    percentontimefiltered_comb int            null,
    pri1expsoon                int            null,
    pri2expsoon                int            null,
    car_exp1date               datetime       null,
    car_exp2date               datetime       null,
    last_chd_id                int            null,
    last_used_date             datetime       null,
    last_billed                money          null,
    last_paid                  money          null,
    total_billed               money          null,
    pay_linehaul               money          null,
    pay_accessorial            money          null,
    pay_fsc                    money          null,
    cty_code                   int            null,
    cty_state                  varchar (6)    null,
    total_trips                int            null,
    total_late                 int            null,
    min_chd_id                 int            null,
    min_billed                 money          null,
    min_paid                   money          null,
    max_chd_id                 int            null,
    max_billed                 money          null,
    max_paid                   money          null,
    --PTS 49332 JJF 20091008
    distance_to_origin         int            null,
    distance_to_destination    int            null,
    --END PTS 49332 JJF 20091008
    preferred_lane             char (1)       null, --PTS52011 MBR 04/23/10
    --PTS 51918 JJF 20110209
    qualification_list_drv     varchar (255)  null,
    qualification_list_trc     varchar (255)  null,
    qualification_list_trl     varchar (255)  null
--END PTS 51918 JJF 20110209
);
--END PTS 49964 JJF 20091221 sqlserver2008 workaround
create table #orig_tars
(
    trk_carrier varchar (8) null,
    tar_number  int         null
);
create table #temp_tars
(
    trk_carrier varchar (8)    null,
    tar_number  int            null,
    tar_rate    decimal (9, 4) null
);
--PTS52011 MBR 04/20/10 added zip to table
declare  @temporigin table
(
    airdistance float        null,
    cty_code    int           primary key,
    cty_nmstct  varchar (30) null,
    cty_zip     varchar (10) null
);
--PTS52011 MBR 04/20/10 added zip to table
declare  @tempdest table
(
    airdistance float        null,
    cty_code    int          primary key,
    cty_nmstct  varchar (30) null,
    cty_zip     varchar (10) null
);
--PTS52011 MBR 04/15/10
declare  @originlanes table
(
    laneid int null
);
declare  @lanes table
(
    laneid int null
);
declare  @lanecarriers table
(
    car_id varchar (8) null
);
/*PTS 50712 CGK 3/31/2010*/
declare  @tempCarrierHistoryDetail table
(
    chd_id          int         null,
    ord_hdrnumber   int         null,
    ord_origincity  int         null,
    ord_originstate varchar (6) null,
    ord_destcity    int         null,
    ord_deststate   varchar (6) null,
    crh_carrier     varchar (8) null,
    lgh_pay         money       null,
    lgh_accessorial money       null,
    lgh_fsc         money       null,
    lgh_billed      money       null,
    lgh_paid        money       null,
    lgh_enddate     datetime    null,
    orders_late     int         null,
    margin          money       null,
    lgh_number      int         null
);
declare @temp_id as int, 
@temp_value as varchar (20), 
@count as int, 
@current_car as varchar (8), 
@ratematch as decimal (9, 4), 
@min_tar_number as int, 
@dhmiles_dest as int, 
@orig_lat as decimal (12, 4), 
@orig_long as decimal (12, 4), 
@dest_lat as decimal (12, 4), 
@dest_long as decimal (12, 4), 
@ls_ocity as varchar (50), 
@ls_ostate as varchar (20), 
@ete_commapos as int, 
@ll_ocity as int, 
@ls_dcity as varchar (50), 
@ls_dstate as varchar (20), 
@ll_dcity as int, 
@use_ocityonly as char (1), 
@state_piece as char (2), 
@use_origzones as varchar (100), 
@origzonestouse as varchar (100), 
@use_origstates as char (1), 
@origstatestouse as varchar (100), 
@use_dcityonly as char (1), 
@use_destzones as varchar (100), 
@destzonestouse as varchar (100), 
@use_deststates as char (1), 
@deststatestouse as varchar (100), 
@daysback as int, 
@currentcar as varchar (8), 
@hoursslack as int, 
@totalordersfiltered as int, 
@ontimeordersfiltered as int, 
@crh_percentfiltered as int, 
@workingOrigin as varchar (58), 
@workingDestination as varchar (58), 
@parse as varchar (50), 
@pos as int, 
@where as varchar (1000), 
@sql as nvarchar (max), 
@ll_ostates as int, 
@ll_dstates as int, 
@slashpos as smallint, 
@ls_ocounty as varchar (3), 
@ls_dcounty as varchar (3), 
@ll_oradius_count as int, 
@ll_dradius_count as int, 
@ls_ostates as varchar (200), 
@ls_dstates as varchar (200), 
@ls_cursorstate as varchar (6), 
@ls_ozip as varchar (10), 
@ls_dzip as varchar (10), 
@ll_lanescount as int;
--PTS 51570 JJF 20100510
declare @rowsecurity as char (1);
--END PTS 51570 JJF 20100510
--PTS 53571 KMM/JJF 20100818
if @cartype1 = ''
   and @cartype2 = ''
   and @cartype3 = ''
   and @cartype4 = ''
   and @liabilitylimit <= 0
   and @cargolimit <= 0
   and isnull(@servicerating, '') = ''
   and (@carid = 'UNKNOWN'
        or ISNULL(@carid, '') = '')
   and isnull(@carname, '') = ''
   and @rateonly = ''
   and isnull(@origin, '') = ''
   and isnull(@destination, '') = ''
   and @insurance = ''
   and @w9 = ''
   and @contract = ''
   and @history = 'N'
   and @domicile = 0
   and isnull(@contact, '') = ''
   and @trcaccess = ''
   and @trlaccess = ''
   and @drvqual = ''
   and @carqual = ''
   and @stp_departure_dt <= '19000101'
   and @returntariffs = 'N'
   and @branch = ''
   and @ratesonly = 'N'
    begin
        -- insert a dummy record
        insert  @temp1 (trk_carrier, car_name)
        values        ('UNKNOWN', 'Please supply either origin or destination and try again.');
        goto ENDPROC;
    end
--END PTS 53571 KMM/JJF 20100818
--PTS 51570 JJF 20100510
select @rowsecurity = gi_string1
from   generalinfo
where  gi_name = 'RowSecurity';

if @ratesonly is null
   or @ratesonly = ''
    set @ratesonly = 'N';
if @carid = 'UNKNOWN'
    set @carid = '';
set @stp_departure_dt = GETDATE();

declare @textdate nvarchar(40)
select @textdate = convert(nvarchar(40),@stp_departure_dt,120)


--SELECT
select @sql = N'select car_id,c.cty_code,cty_latitude,cty_longitude,cty_state,''N'',''N'',''Y'' '

--FROM
select @sql = @sql + N'from carrier c with (nolock) inner join city with (nolock) on c.cty_code = city.cty_code '

if @rowsecurity = 'Y'
select @sql = @sql + N'inner join RowRestrictValidAssignments_carrier_fn() rsva ON c.rowsec_rsrv_id = rsva.rowsec_rsrv_id OR rsva.rowsec_rsrv_id = 0 '

if LEN(@carqual) > 0
select @sql = @sql + N'inner join carrierqualifications cq ON c.car_id = cq.caq_id '

if LEN(@trlaccess) > 0
select @sql = @sql + N'inner join trlaccessories ta on c.car_id = ta.ta_trailer '

if LEN(@trcaccess) > 0
select @sql = @sql + N'inner join tractoraccesories tca on c.car_id = tca.tca_tractor '

if LEN(@drvqual) > 0
select @sql = @sql + N'inner join driverqualifications drq on c.car_id = drq.drq_id '

--WHERE
select @sql = @sql + N'where city.cty_code > 0 and isNull(city.cty_fuelcreate, 0) = 0 and c.car_status <> ''OUT'' '

if LEN(@carqual) > 0
begin
	select @sql = @sql + N'and ISNULL(cq.caq_expire_flag, ''N'') <> ''Y'' AND cq.caq_expire_date >= ''' + @textdate + ''' AND '
	select @carqual = replace(@carqual,',',') and (')
	select @sql = @sql + N'(' + @carqual + N') '
end

if LEN(@trlaccess) > 0
begin
	select @sql = @sql + N'and ta.ta_source = ''CAR'' AND ISNULL(ta.ta_expire_flag, ''N'') <> ''Y'' AND ta.ta_expire_date >= ''' + @textdate + ''' AND '
	select @trlaccess = replace(@trlaccess,',',') and (')
	select @sql = @sql + N'(' + @trlaccess + N') '
end

--'tca_type = ''PUMP'' and tca_quantitiy > 0'

if LEN(@trcaccess) > 0
begin
	select @sql = @sql + N'and tca.tca_source = ''CAR'' AND ISNULL(tca.tca_expire_flag, ''N'') <> ''Y'' AND tca.tca_expire_date >= ''' + @textdate + ''' AND '
	
	select @trcaccess = replace(@trcaccess,',',') and (')
	select @sql = @sql + N'(' + @trcaccess + N') '
end

if LEN(@drvqual) > 0
begin
	select @sql = @sql + N'and drq.drq_source = ''CAR'' AND ISNULL(drq.drq_expire_flag, ''N'') <> ''Y'' AND drq.drq_expire_date >= ''' + @textdate + ''' AND '
	select @drvqual = replace(@drvqual,',',') and (')
	select @sql = @sql + N'(' + @drvqual + N') '
end


if not (@cartype1 = 'UNK' or @cartype1 = '' or @cartype1 is null)
	select @sql = @sql + N'and c.car_type1 = @cartype1 '
	
if not (@cartype2 = 'UNK' or @cartype2 = '' or @cartype2 is null)
	select @sql = @sql + N'and c.car_type2 = @cartype2 '
	
if not (@cartype3 = 'UNK' or @cartype3 = '' or @cartype3 is null)
	select @sql = @sql + N'and c.car_type3 = @cartype3 '
	
if not (@cartype4 = 'UNK' or @cartype4 = '' or @cartype4 is null)
	select @sql = @sql + N'and c.car_type4 = @cartype4 '

if not (@liabilitylimit = 0 or @liabilitylimit is null)
	select @sql = @sql + N'and @liabilitylimit <= c.car_ins_liabilitylimits '
	
if not (@cargolimit = 0 or @cargolimit is null)
	select @sql = @sql + N'and @cargolimit <= c.car_ins_cargolimits '

if not (@servicerating = 'UNK' or @servicerating = '' or @servicerating is null)
	select @sql = @sql + N'and c.car_rating = @servicerating '

if not (@carname is null or @carname = '')
	select @sql = @sql + N'and c.car_name like @carname + ''%'' '
	
if not (@contact is null or @contact = '')
	select @sql = @sql + N'and c.car_contact like @contact + ''%'' '
	
if not (@insurance is null or @insurance = '' or @insurance = 'N')
	select @sql = @sql + N'and car_ins_certificate = @insurance '
	
if not (@w9 is null or @w9 = '' or @w9 = 'N')
	select @sql = @sql + N'and car_ins_w9 = @w9 '
	
if not (@contract is null or @contract = '' or @contract = 'N')
	select @sql = @sql + N'and car_ins_contract = @contract '
	
if not (@branch is null or @branch = '' or @branch = 'UNK' or @branch = 'UNKNOWN')
	select @sql = @sql + N'and c.car_branch = @branch '

if @returntariffs = 'N' and not(@carid is null or @carid = '')
	select @sql = @sql + N'and c.car_id like @carid + ''%'' '
else if @returntariffs = 'Y'
	select @sql = @sql + N'and c.car_id = @carid '

select @sql = @sql + N'order by c.car_id'


-- Get first list of carriers for @temp_filteredcarriers.
insert @temp_filteredcarriers (fcr_carrier, fcr_car_city, fcr_dom_lat, fcr_dom_long, fcr_domicile_state, fcr_origdomicile, fcr_destdomicile, keepfromfilter)
execute sp_executesql @sql, 
@params=N'@cartype1 varchar(6), 
@cartype2 varchar(6), 
@cartype3 varchar(6), 
@cartype4 varchar(6), 
@liabilitylimit money, 
@cargolimit money, 
@servicerating varchar(6), 
@carid varchar(8), 
@carname varchar(64), 
@contact varchar(30), 
@insurance char(1), 
@w9 char(1), 
@contract char(1), 
@branch varchar(12), 
@returntariffs char(1)',
@cartype1=@cartype1, 
@cartype2=@cartype2, 
@cartype3=@cartype3, 
@cartype4=@cartype4, 
@liabilitylimit=@liabilitylimit, 
@cargolimit=@cargolimit, 
@servicerating=@servicerating, 
@carid=@carid, 
@carname=@carname, 
@contact=@contact, 
@insurance=@insurance, 
@w9=@w9, 
@contract=@contract, 
@branch=@branch, 
@returntariffs=@returntariffs;

-- parse origin and destination args
set @ll_ocity = 0;
set @ll_ostates = 0;
set @ll_dcity = 0;
set @ll_dstates = 0;
set @origin = UPPER(LTRIM(RTRIM(@origin)));
if LEN(@origin) > 0
    begin
        set @ete_commapos = CHARINDEX(',', @origin);
        set @slashpos = CHARINDEX('/', @origin);
        if @ete_commapos > 0
            begin
                if @slashpos > 0
                    begin
                        set @ls_ocity = RTRIM(LTRIM(left(@origin, (@ete_commapos - 1))));
                        set @ls_ostate = RTRIM(LTRIM(SUBSTRING(@origin, (@ete_commapos + 1), (@slashpos - (@ete_commapos + 1)))));
                        set @ls_ocounty = RTRIM(LTRIM(right(@origin, (LEN(@origin) - @slashpos))));
                        set @ls_ocounty = SUBSTRING(@ls_ocounty, 1, 3);
                        --PTS 53571 KMM/JJF 20100818 add nolock
                        select @ll_ocity = cty_code,
                               @orig_lat = ISNULL(cty_latitude, 0),
                               @orig_long = ISNULL(cty_longitude, 0),
                               @ls_ozip = cty_zip
                        from   city with (nolock)
                        where  cty_name = @ls_ocity
                               and cty_state = @ls_ostate
                               and isNull(cty_fuelcreate, 0) = 0
                               --PTS 49405 JJF 20091009
                               --cty_county = @ls_ocounty
                               and (cty_county = @ls_ocounty
                                    or isnull(@ls_ocounty, '') = '');
                        --END PTS 49405 JJF 20091009
                        if @ll_ocity is null
                            set @ll_ocity = 0;
                    end
                else
                    begin
                        set @ls_ocity = RTRIM(LTRIM(left(@origin, (@ete_commapos - 1))));
                        set @ls_ostate = RTRIM(LTRIM(right(@origin, (LEN(@origin) - @ete_commapos))));
                        --PTS 53571 KMM/JJF 20100818 add nolock
                        select @ll_ocity = cty_code,
                               @orig_lat = ISNULL(cty_latitude, 0),
                               @orig_long = ISNULL(cty_longitude, 0),
                               @ls_ozip = cty_zip
                        from   city with (nolock)
                        where  cty_name = @ls_ocity
                               and cty_state = @ls_ostate
                               and isNull(cty_fuelcreate, 0) = 0;
                        if @ll_ocity is null
                            set @ll_ocity = 0;
                    end
            end
        else
            begin
                while LEN(@origin) >= 2
                    begin
                        set @state_piece = left(@origin, 2);
                        if left(@state_piece, 1) = 'Z'
                            insert into @origin_states
                            --PTS 53571 KMM/JJF 20100818 add nolock
                            select tcz_state
                            from   transcore_zones with (nolock)
                            where  tcz_zone = @state_piece;
                        else
                            insert  into @origin_states (origin_state)
                            values                     (@state_piece);
                        set @origin = right(@origin, (LEN(@origin) - 2));
                    end
                select @ll_ostates = COUNT(distinct origin_state)
                from   @origin_states;
            end
    end
--If origin is a city and radius is set and lat/longs found in city file,
--find all cities within radius
if @ll_ocity > 0
   and @oradius > 0
    begin
        if @orig_lat > 0
           and @orig_long > 0
            begin
                insert into @temporigin
                execute TMW_CITIESWITHINRADIUS_SP @orig_lat, @orig_long, @oradius;
                select @ll_oradius_count = COUNT(*)
                from   @temporigin;
                if @ll_oradius_count is null
                    set @ll_oradius_count = 0;
                if @ll_oradius_count = 0
                    set @oradius = 0;
            end
        else
            begin
                set @oradius = 0;
            end
    end
--If origin is not a city and the radius is set, zero the radius
if @ll_ocity = 0
    set @oradius = 0;
set @destination = UPPER(LTRIM(RTRIM(@destination)));
if LEN(@destination) > 0
    begin
        set @ete_commapos = CHARINDEX(',', @destination);
        set @slashpos = CHARINDEX('/', @destination);
        if @ete_commapos > 0
            begin
                if @slashpos > 0
                    begin
                        set @ls_dcity = RTRIM(LTRIM(left(@destination, (@ete_commapos - 1))));
                        set @ls_dstate = RTRIM(LTRIM(SUBSTRING(@destination, (@ete_commapos + 1), (@slashpos - (@ete_commapos + 1)))));
                        set @ls_dcounty = RTRIM(LTRIM(right(@destination, (LEN(@destination) - @slashpos))));
                        set @ls_dcounty = SUBSTRING(@ls_dcounty, 1, 3);
                        --PTS 53571 KMM/JJF 20100818 add nolock
                        select @ll_dcity = cty_code,
                               @dest_lat = ISNULL(cty_latitude, 0),
                               @dest_long = ISNULL(cty_longitude, 0),
                               @ls_dzip = cty_zip
                        from   city with (nolock)
                        where  cty_name = @ls_dcity
                               and cty_state = @ls_dstate
                               and isNull(cty_fuelcreate, 0) = 0
                               --PTS 49405 JJF 20091009
                               --cty_county = @@ls_dcounty
                               and (cty_county = @ls_dcounty
                                    or isnull(@ls_dcounty, '') = '');
                        --END PTS 49405 JJF 20091009
                        if @ll_dcity is null
                            set @ll_dcity = 0;
                    end
                else
                    begin
                        set @ls_dcity = RTRIM(LTRIM(left(@destination, (@ete_commapos - 1))));
                        set @ls_dstate = RTRIM(LTRIM(right(@destination, (LEN(@destination) - @ete_commapos))));
                        --PTS 53571 KMM/JJF 20100818 add nolock
                        select @ll_dcity = cty_code,
                               @dest_lat = ISNULL(cty_latitude, 0),
                               @dest_long = ISNULL(cty_longitude, 0),
                               @ls_dzip = cty_zip
                        from   city with (nolock)
                        where  cty_name = @ls_dcity
                               and cty_state = @ls_dstate
                               and isNull(cty_fuelcreate, 0) = 0;
                        if @ll_dcity is null
                            set @ll_dcity = 0;
                    end
            end
        else
            begin
                while LEN(@destination) >= 2
                    begin
                        set @state_piece = left(@destination, 2);
                        if left(@state_piece, 1) = 'Z'
                            --PTS 53571 KMM/JJF 20100818 add nolock
                            insert into @destination_states
                            select tcz_state
                            from   transcore_zones with (nolock)
                            where  tcz_zone = @state_piece;
                        else
                            insert  into @destination_states (destination_state)
                            values                          (@state_piece);
                        set @destination = right(@destination, (LEN(@destination) - 2));
                    end
                select @ll_dstates = COUNT(distinct destination_state)
                from   @destination_states;
            end
    end
--If destination is a city and radius is set and lat/longs found in city file,
--find all cities within radius
if @ll_dcity > 0
   and @dradius > 0
    begin
        if @dest_lat > 0
           and @dest_long > 0
            begin
                insert into @tempdest
                execute TMW_CITIESWITHINRADIUS_SP @dest_lat, @dest_long, @dradius;
                select @ll_dradius_count = COUNT(*)
                from   @tempdest;
                if @ll_dradius_count is null
                    set @ll_dradius_count = 0;
                if @ll_dradius_count = 0
                    set @dradius = 0;
            end
        else
            begin
                set @dradius = 0;
            end
    end
--If destination is not a city, zero the dradius
if @ll_dcity = 0
    set @dradius = 0;
if @ll_ostates > 0
    begin
        set @ls_ostates = ',';
        declare origin_cursor cursor
            for select distinct origin_state
                from   @origin_states;
        open origin_cursor;
        fetch next from origin_cursor into @ls_cursorstate;
        while @@FETCH_STATUS = 0
            begin
                set @ls_ostates = @ls_ostates + @ls_cursorstate + ',';
                fetch next from origin_cursor into @ls_cursorstate;
            end
        close origin_cursor;
        deallocate origin_cursor;
    end
if @ll_dstates > 0
    begin
        set @ls_dstates = ',';
        declare dest_cursor cursor
            for select distinct destination_state
                from   @destination_states;
        open dest_cursor;
        fetch next from dest_cursor into @ls_cursorstate;
        while @@FETCH_STATUS = 0
            begin
                set @ls_dstates = @ls_dstates + @ls_cursorstate + ',';
                fetch next from dest_cursor into @ls_cursorstate;
            end
        close dest_cursor;
        deallocate dest_cursor;
    end
/*PTS 50712 CGK 3/31/2010*/
--PTS 53571 KMM/JJF 20100818 add nolock

if @oradius = 0 and @dradius = 0
begin
		insert into @tempCarrierHistoryDetail (chd_id, ord_hdrnumber, ord_origincity, ord_originstate, ord_destcity, ord_deststate, crh_carrier, lgh_pay, lgh_accessorial, lgh_fsc, lgh_billed, lgh_paid, lgh_enddate, orders_late, margin, lgh_number)
		select chd.chd_id,
			   chd.ord_hdrnumber,
			   chd.ord_origincity,
			   chd.ord_originstate,
			   chd.ord_destcity,
			   chd.ord_deststate,
			   chd.Crh_Carrier,
			   chd.lgh_pay,
			   chd.lgh_accessorial,
			   chd.lgh_fsc,
			   chd.lgh_billed,
			   chd.lgh_paid,
			   chd.lgh_enddate,
			   chd.orders_late,
			   chd.margin,
			   chd.lgh_number
		from   carrierhistorydetail  chd inner join @temp_filteredcarriers tf on
		chd.crh_carrier = tf.fcr_carrier
		where  
			(
				(@ll_ocity = 0 or chd.ord_origincity = @ll_ocity)
					and (@ll_ostates = 0 or CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)
					and (@ll_dcity = 0 or chd.ord_destcity = @ll_dcity)
					and (@ll_dstates = 0 or CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0)
			);
end
else if @oradius = 0 and @dradius >  0
begin
		insert into @tempCarrierHistoryDetail (chd_id, ord_hdrnumber, ord_origincity, ord_originstate, ord_destcity, ord_deststate, crh_carrier, lgh_pay, lgh_accessorial, lgh_fsc, lgh_billed, lgh_paid, lgh_enddate, orders_late, margin, lgh_number)
		select chd.chd_id,
			   chd.ord_hdrnumber,
			   chd.ord_origincity,
			   chd.ord_originstate,
			   chd.ord_destcity,
			   chd.ord_deststate,
			   chd.Crh_Carrier,
			   chd.lgh_pay,
			   chd.lgh_accessorial,
			   chd.lgh_fsc,
			   chd.lgh_billed,
			   chd.lgh_paid,
			   chd.lgh_enddate,
			   chd.orders_late,
			   chd.margin,
			   chd.lgh_number
		from   carrierhistorydetail  chd inner join @temp_filteredcarriers tf on
		chd.crh_carrier = tf.fcr_carrier
		inner join @tempdest td on chd.ord_destcity = td.cty_code
		where  
			(
			(@ll_ocity = 0 or chd.ord_origincity = @ll_ocity)
			and (@ll_ostates = 0 or CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)
			);
end
else if @oradius > 0 and @dradius =  0
begin
		insert into @tempCarrierHistoryDetail (chd_id, ord_hdrnumber, ord_origincity, ord_originstate, ord_destcity, ord_deststate, crh_carrier, lgh_pay, lgh_accessorial, lgh_fsc, lgh_billed, lgh_paid, lgh_enddate, orders_late, margin, lgh_number)
		select chd.chd_id,
			   chd.ord_hdrnumber,
			   chd.ord_origincity,
			   chd.ord_originstate,
			   chd.ord_destcity,
			   chd.ord_deststate,
			   chd.Crh_Carrier,
			   chd.lgh_pay,
			   chd.lgh_accessorial,
			   chd.lgh_fsc,
			   chd.lgh_billed,
			   chd.lgh_paid,
			   chd.lgh_enddate,
			   chd.orders_late,
			   chd.margin,
			   chd.lgh_number
		from   carrierhistorydetail  chd inner join @temp_filteredcarriers tf on
		chd.crh_carrier = tf.fcr_carrier 
		inner join @temporigin tor on chd.ord_origincity = tor.cty_code
		where  

			   (
						(@ll_dcity = 0 or chd.ord_destcity = @ll_dcity)
						and (@ll_dstates = 0 or CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0)
				);
end
else if @oradius > 0 and @dradius >  0
begin
		insert into @tempCarrierHistoryDetail (chd_id, ord_hdrnumber, ord_origincity, ord_originstate, ord_destcity, ord_deststate, crh_carrier, lgh_pay, lgh_accessorial, lgh_fsc, lgh_billed, lgh_paid, lgh_enddate, orders_late, margin, lgh_number)
		select chd.chd_id,
			   chd.ord_hdrnumber,
			   chd.ord_origincity,
			   chd.ord_originstate,
			   chd.ord_destcity,
			   chd.ord_deststate,
			   chd.Crh_Carrier,
			   chd.lgh_pay,
			   chd.lgh_accessorial,
			   chd.lgh_fsc,
			   chd.lgh_billed,
			   chd.lgh_paid,
			   chd.lgh_enddate,
			   chd.orders_late,
			   chd.margin,
			   chd.lgh_number
		from   carrierhistorydetail  chd inner join @temp_filteredcarriers tf on
		chd.crh_carrier = tf.fcr_carrier
		inner join @temporigin tor on chd.ord_origincity = tor.cty_code
		inner join @tempdest td on chd.ord_destcity = td.cty_code;
end


declare @cartypes1 varchar(20), @cartypes2 varchar(20), @cartypes3 varchar(20), @cartypes4 varchar(20)
select @cartypes1 = MAX(cartype1), @cartypes2 = max(cartype2), @cartypes3 = max(cartype3), @cartypes4 = max(cartype4) from   labelfile_headers with (nolock);

if (@oradius = 0 and @dradius = 0)
begin
	insert into @temp1 (trk_carrier, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, dest_domicile, rateonfileorigin, total_billed, pay_linehaul, pay_accessorial, pay_fsc, last_chd_id, total_trips, total_late, min_chd_id, max_chd_id, /*PTS 50712 CGK 3/31/2010*/ max_billed, max_paid, min_billed, min_paid, min_margin_amount, max_margin_amount, min_margin_percent, max_margin_percent, /*END PTS 50712 CGK 3/31/2010*/
	preferred_lane)
	select ch.crh_carrier,
		   crh_total,
		   crh_ontime,
		   crh_percent,
		   crh_avefuel,
		   crh_avetotal,
		   crh_aveacc,
		   ISNULL(carrier.car_name, ''),
		   ISNULL(carrier.car_address1, ''),
		   ISNULL(carrier.car_address2, ''),
		   ISNULL(carrier.car_scac, ''),
		   ISNULL(carrier.car_Phone1, ''),
		   ISNULL(carrier.car_Phone2, ''),
		   ISNULL(carrier.car_contact, ''),
		   ISNULL(carrier.car_phone3, ''),
		   ISNULL(carrier.car_email, ''),
		   ISNULL(carrier.car_currency, ''),
		   (select name
			from   labelfile with (nolock)
			where  labeldefinition = 'CarrierServiceRating'
				   and abbr = carrier.car_rating),
		   @cartypes1,
		   @cartypes2,
		   @cartypes3,
		   @cartypes4,
		   carrier.car_type1,
		   carrier.car_type2,
		   carrier.car_type3,
		   carrier.car_type4,
		   city.cty_nmstct,
		   carrier.cty_code,
		   city.cty_state,
		   'Y',
		   'N',
		   'N',
		   'N',
		   /*Start PTS 50712 CGK 3/31/2010*/
			sum(isnull(lgh_billed, 0)),
			sum(isnull(lgh_pay, 0)),
			sum(isnull(lgh_accessorial, 0)),
			sum(isnull(lgh_fsc, 0)),
			null, --last_chd_id
			COUNT(*),
			0, --total late
		   0,
		   0,
		   MAX(chd.lgh_billed),
		   MAX(chd.lgh_paid),
		   MIN(chd.lgh_billed), 
		   MIN(chd.lgh_paid),
		   MIN(lgh_billed - lgh_paid),
		   MAX(lgh_billed - lgh_paid),
		   MIN(margin),
		   MAX(margin),
		   'N'      
		   from carrierhistory ch 
			inner join carrier on ch.crh_carrier = carrier.car_id
			inner join city on carrier.cty_code = city.cty_code
			inner join @temp_filteredcarriers tf on ch.crh_carrier = tf.fcr_carrier
			inner join @tempCarrierHistoryDetail chd on chd.crh_carrier = ch.crh_carrier

	where  ch.crh_carrier in (select distinct chd.crh_carrier
						   from   carrierhistorydetail as chd with (nolock)
						   where  (@ll_ocity = 0 or chd.ord_origincity = @ll_ocity) and 
								  (@ll_ostates = 0 or CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0))
						   and	  ((@ll_dcity = 0 or chd.ord_destcity = @ll_dcity) and 
								  (@ll_dstates = 0 or CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0))
									  
	group by
		   ch.crh_carrier,
		   crh_total,
		   crh_ontime,
		   crh_percent,
		   crh_avefuel,
		   crh_avetotal,
		   crh_aveacc,
		   ISNULL(carrier.car_name, ''),
		   ISNULL(carrier.car_address1, ''),
		   ISNULL(carrier.car_address2, ''),
		   ISNULL(carrier.car_scac, ''),
		   ISNULL(carrier.car_Phone1, ''),
		   ISNULL(carrier.car_Phone2, ''),
		   ISNULL(carrier.car_contact, ''),
		   ISNULL(carrier.car_phone3, ''),
		   ISNULL(carrier.car_email, ''),
		   ISNULL(carrier.car_currency, ''),
		   carrier.car_rating,
		   carrier.car_type1,
		   carrier.car_type2,
		   carrier.car_type3,
		   carrier.car_type4,
		   city.cty_nmstct,
		   carrier.cty_code,
		   city.cty_state
end
else if (@oradius = 0 and @dradius > 0)
begin
	insert into @temp1 (trk_carrier, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, dest_domicile, rateonfileorigin, total_billed, pay_linehaul, pay_accessorial, pay_fsc, last_chd_id, total_trips, total_late, min_chd_id, max_chd_id, /*PTS 50712 CGK 3/31/2010*/ max_billed, max_paid, min_billed, min_paid, min_margin_amount, max_margin_amount, min_margin_percent, max_margin_percent, preferred_lane)
	select ch.crh_carrier,
		   crh_total,
		   crh_ontime,
		   crh_percent,
		   crh_avefuel,
		   crh_avetotal,
		   crh_aveacc,
		   ISNULL(carrier.car_name, ''),
		   ISNULL(carrier.car_address1, ''),
		   ISNULL(carrier.car_address2, ''),
		   ISNULL(carrier.car_scac, ''),
		   ISNULL(carrier.car_Phone1, ''),
		   ISNULL(carrier.car_Phone2, ''),
		   ISNULL(carrier.car_contact, ''),
		   ISNULL(carrier.car_phone3, ''),
		   ISNULL(carrier.car_email, ''),
		   ISNULL(carrier.car_currency, ''),
		   (select name
			from   labelfile with (nolock)
			where  labeldefinition = 'CarrierServiceRating'
				   and abbr = carrier.car_rating),
		   @cartypes1,
		   @cartypes2,
		   @cartypes3,
		   @cartypes4,
		   carrier.car_type1,
		   carrier.car_type2,
		   carrier.car_type3,
		   carrier.car_type4,
		   city.cty_nmstct,
		   carrier.cty_code,
		   city.cty_state,
		   'Y',
		   'N',
		   'N',
		   'N',
		   /*Start PTS 50712 CGK 3/31/2010*/
			sum(isnull(lgh_billed, 0)),
			sum(isnull(lgh_pay, 0)),
			sum(isnull(lgh_accessorial, 0)),
			sum(isnull(lgh_fsc, 0)),
			null, --last_chd_id
			COUNT(*),
			0, --total late
		   0,
		   0,
		   MAX(chd.lgh_billed),
		   MAX(chd.lgh_paid),
		   MIN(chd.lgh_billed), 
		   MIN(chd.lgh_paid),
		   MIN(lgh_billed - lgh_paid),
		   MAX(lgh_billed - lgh_paid),
		   MIN(margin),
		   MAX(margin),
		   'N'      
		   from carrierhistory ch 
			inner join carrier on ch.crh_carrier = carrier.car_id
			inner join city on carrier.cty_code = city.cty_code
			inner join @temp_filteredcarriers tf on ch.crh_carrier = tf.fcr_carrier
			inner join @tempCarrierHistoryDetail chd on chd.crh_carrier = ch.crh_carrier
			inner join @tempdest td on chd.ord_destcity = td.cty_code

	where  ch.crh_carrier in (select distinct chd.crh_carrier
						   from   carrierhistorydetail as chd with (nolock)
						   where  (@ll_ocity = 0 or chd.ord_origincity = @ll_ocity) and 
								  (@ll_ostates = 0 or CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0))
	group by
		   ch.crh_carrier,
		   crh_total,
		   crh_ontime,
		   crh_percent,
		   crh_avefuel,
		   crh_avetotal,
		   crh_aveacc,
		   ISNULL(carrier.car_name, ''),
		   ISNULL(carrier.car_address1, ''),
		   ISNULL(carrier.car_address2, ''),
		   ISNULL(carrier.car_scac, ''),
		   ISNULL(carrier.car_Phone1, ''),
		   ISNULL(carrier.car_Phone2, ''),
		   ISNULL(carrier.car_contact, ''),
		   ISNULL(carrier.car_phone3, ''),
		   ISNULL(carrier.car_email, ''),
		   ISNULL(carrier.car_currency, ''),
		   carrier.car_rating,
		   carrier.car_type1,
		   carrier.car_type2,
		   carrier.car_type3,
		   carrier.car_type4,
		   city.cty_nmstct,
		   carrier.cty_code,
		   city.cty_state
end 
else if (@oradius > 0 and @dradius = 0)
begin
	insert into @temp1 (trk_carrier, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, dest_domicile, rateonfileorigin, total_billed, pay_linehaul, pay_accessorial, pay_fsc, last_chd_id, total_trips, total_late, min_chd_id, max_chd_id, /*PTS 50712 CGK 3/31/2010*/ max_billed, max_paid, min_billed, min_paid, min_margin_amount, max_margin_amount, min_margin_percent, max_margin_percent, /*END PTS 50712 CGK 3/31/2010*/
	preferred_lane)
	select ch.crh_carrier,
		   crh_total,
		   crh_ontime,
		   crh_percent,
		   crh_avefuel,
		   crh_avetotal,
		   crh_aveacc,
		   ISNULL(carrier.car_name, ''),
		   ISNULL(carrier.car_address1, ''),
		   ISNULL(carrier.car_address2, ''),
		   ISNULL(carrier.car_scac, ''),
		   ISNULL(carrier.car_Phone1, ''),
		   ISNULL(carrier.car_Phone2, ''),
		   ISNULL(carrier.car_contact, ''),
		   ISNULL(carrier.car_phone3, ''),
		   ISNULL(carrier.car_email, ''),
		   ISNULL(carrier.car_currency, ''),
		   (select name
			from   labelfile with (nolock)
			where  labeldefinition = 'CarrierServiceRating'
				   and abbr = carrier.car_rating),
		   @cartypes1,
		   @cartypes2,
		   @cartypes3,
		   @cartypes4,
		   carrier.car_type1,
		   carrier.car_type2,
		   carrier.car_type3,
		   carrier.car_type4,
		   city.cty_nmstct,
		   carrier.cty_code,
		   city.cty_state,
		   'Y',
		   'N',
		   'N',
		   'N',
		   /*Start PTS 50712 CGK 3/31/2010*/
			sum(isnull(lgh_billed, 0)),
			sum(isnull(lgh_pay, 0)),
			sum(isnull(lgh_accessorial, 0)),
			sum(isnull(lgh_fsc, 0)),
			null, --last_chd_id
			COUNT(*),
			0, --total late
		   0,
		   0,
		   MAX(chd.lgh_billed),
		   MAX(chd.lgh_paid),
		   MIN(chd.lgh_billed), 
		   MIN(chd.lgh_paid),
		   MIN(lgh_billed - lgh_paid),
		   MAX(lgh_billed - lgh_paid),
		   MIN(margin),
		   MAX(margin),
		   'N'      
		   from carrierhistory ch 
			inner join carrier on ch.crh_carrier = carrier.car_id
			inner join city on carrier.cty_code = city.cty_code
			inner join @temp_filteredcarriers tf on ch.crh_carrier = tf.fcr_carrier
			inner join @tempCarrierHistoryDetail chd on chd.crh_carrier = ch.crh_carrier
			inner join @temporigin tor on chd.ord_origincity = tor.cty_code
	where  ch.crh_carrier in (select distinct chd.crh_carrier
						   from   carrierhistorydetail as chd 
						   where  (@ll_dcity = 0 or chd.ord_destcity = @ll_dcity) and 
								  (@ll_dstates = 0 or CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0))
									  
	group by
		   ch.crh_carrier,
		   crh_total,
		   crh_ontime,
		   crh_percent,
		   crh_avefuel,
		   crh_avetotal,
		   crh_aveacc,
		   ISNULL(carrier.car_name, ''),
		   ISNULL(carrier.car_address1, ''),
		   ISNULL(carrier.car_address2, ''),
		   ISNULL(carrier.car_scac, ''),
		   ISNULL(carrier.car_Phone1, ''),
		   ISNULL(carrier.car_Phone2, ''),
		   ISNULL(carrier.car_contact, ''),
		   ISNULL(carrier.car_phone3, ''),
		   ISNULL(carrier.car_email, ''),
		   ISNULL(carrier.car_currency, ''),
		   carrier.car_rating,
		   carrier.car_type1,
		   carrier.car_type2,
		   carrier.car_type3,
		   carrier.car_type4,
		   city.cty_nmstct,
		   carrier.cty_code,
		   city.cty_state
end
else if (@oradius > 0 and @dradius > 0)
begin
	insert into @temp1 (trk_carrier, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, dest_domicile, rateonfileorigin, total_billed, pay_linehaul, pay_accessorial, pay_fsc, last_chd_id, total_trips, total_late, min_chd_id, max_chd_id, /*PTS 50712 CGK 3/31/2010*/ max_billed, max_paid, min_billed, min_paid, min_margin_amount, max_margin_amount, min_margin_percent, max_margin_percent, /*END PTS 50712 CGK 3/31/2010*/ preferred_lane)
	select ch.crh_carrier,
		   crh_total,
		   crh_ontime,
		   crh_percent,
		   crh_avefuel,
		   crh_avetotal,
		   crh_aveacc,
		   ISNULL(carrier.car_name, ''),
		   ISNULL(carrier.car_address1, ''),
		   ISNULL(carrier.car_address2, ''),
		   ISNULL(carrier.car_scac, ''),
		   ISNULL(carrier.car_Phone1, ''),
		   ISNULL(carrier.car_Phone2, ''),
		   ISNULL(carrier.car_contact, ''),
		   ISNULL(carrier.car_phone3, ''),
		   ISNULL(carrier.car_email, ''),
		   ISNULL(carrier.car_currency, ''),
		   (select name
			from   labelfile with (nolock)
			where  labeldefinition = 'CarrierServiceRating'
				   and abbr = carrier.car_rating),
		   @cartypes1,
		   @cartypes2,
		   @cartypes3,
		   @cartypes4,
		   carrier.car_type1,
		   carrier.car_type2,
		   carrier.car_type3,
		   carrier.car_type4,
		   city.cty_nmstct,
		   carrier.cty_code,
		   city.cty_state,
		   'Y',
		   'N',
		   'N',
		   'N',
		   /*Start PTS 50712 CGK 3/31/2010*/
			sum(isnull(lgh_billed, 0)),
			sum(isnull(lgh_pay, 0)),
			sum(isnull(lgh_accessorial, 0)),
			sum(isnull(lgh_fsc, 0)),
			null, --last_chd_id
			COUNT(*),
			0, --total late
		   0,
		   0,
		   MAX(chd.lgh_billed),
		   MAX(chd.lgh_paid),
		   MIN(chd.lgh_billed), 
		   MIN(chd.lgh_paid),
		   MIN(lgh_billed - lgh_paid),
		   MAX(lgh_billed - lgh_paid),
		   MIN(margin),
		   MAX(margin),
		   'N'      
		   from carrierhistory ch 
			inner join carrier on ch.crh_carrier = carrier.car_id
			inner join city on carrier.cty_code = city.cty_code
			inner join @temp_filteredcarriers tf on ch.crh_carrier = tf.fcr_carrier
			inner join @tempCarrierHistoryDetail chd on chd.crh_carrier = ch.crh_carrier
			inner join @temporigin tor on chd.ord_origincity = tor.cty_code
			inner join @tempdest td on chd.ord_destcity = td.cty_code
	where  ch.crh_carrier in (select distinct chd.crh_carrier from carrierhistorydetail chd)
	group by
		   ch.crh_carrier,
		   crh_total,
		   crh_ontime,
		   crh_percent,
		   crh_avefuel,
		   crh_avetotal,
		   crh_aveacc,
		   ISNULL(carrier.car_name, ''),
		   ISNULL(carrier.car_address1, ''),
		   ISNULL(carrier.car_address2, ''),
		   ISNULL(carrier.car_scac, ''),
		   ISNULL(carrier.car_Phone1, ''),
		   ISNULL(carrier.car_Phone2, ''),
		   ISNULL(carrier.car_contact, ''),
		   ISNULL(carrier.car_phone3, ''),
		   ISNULL(carrier.car_email, ''),
		   ISNULL(carrier.car_currency, ''),
		   carrier.car_rating,
		   carrier.car_type1,
		   carrier.car_type2,
		   carrier.car_type3,
		   carrier.car_type4,
		   city.cty_nmstct,
		   carrier.cty_code,
		   city.cty_state
end

--update last chd_id here  ISNULL(chd_id, 0) as last_chd_id
update @temp1
set last_chd_id = tchd.chd_id from 
@tempCarrierHistoryDetail tchd inner join
(select  crh_carrier, max(lgh_enddate) as max_lgh_enddate 
        from     @tempCarrierHistoryDetail chd inner join @temp1 t
        on    chd.crh_carrier = t.trk_carrier
                 where ((@oradius = 0
                       and (@ll_ocity = 0
                            or chd.ord_origincity = @ll_ocity)
                       and (@ll_ostates = 0
                            or CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0))
                      or (@oradius > 0
                          and chd.ord_origincity in (select cty_code
                                                     from   @temporigin)))
                 and ((@dradius = 0
                       and (@ll_dcity = 0
                            or chd.ord_destcity = @ll_dcity)
                       and (@ll_dstates = 0
                            or CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0))
                      or (@dradius > 0
                          and chd.ord_destcity in (select cty_code
                                                   from   @tempdest)))
        group by crh_carrier) c on tchd.crh_carrier = c.crh_carrier and tchd.lgh_enddate = c.max_lgh_enddate
		inner join @temp1 t1 on c.crh_carrier = t1.trk_carrier;

--update total late here
update  @temp1
set total_late = c.qty from 
(select crh_carrier, COUNT(*) as qty
        from   @tempCarrierHistoryDetail chd inner join @temp1 t on
          chd.crh_carrier = t.trk_carrier
               where ((@oradius = 0
                     and (@ll_ocity = 0
                          or chd.ord_origincity = @ll_ocity)
                     and (@ll_ostates = 0
                          or CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0))
                    or (@oradius > 0
                        and chd.ord_origincity in (select cty_code
                                                   from   @temporigin)))
               and ((@dradius = 0
                     and (@ll_dcity = 0
                          or chd.ord_destcity = @ll_dcity)
                     and (@ll_dstates = 0
                          or CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0))
                    or (@dradius > 0
                        and chd.ord_destcity in (select cty_code
                                                 from   @tempdest)))
               and chd.orders_late > 0 group by crh_carrier) c
inner join @temp1 t1 on c.crh_carrier = t1.trk_carrier;

--PTS 53571 KMM/JJF 20100818 add nolock
update  @temp1
    set last_used_date = chd.lgh_enddate,
        last_billed    = chd.lgh_billed,
        last_paid      = ISNULL(chd.lgh_paid, 0)
from    carrierhistorydetail as chd with (nolock) inner join @temp1 t on t.last_chd_id = chd.chd_id
where   t.last_chd_id > 0;







if @ll_ocity > 0
   and @oradius = 0
    begin
        if @ls_ozip is not null
           and @ls_ozip <> ''
           and @ls_ozip <> '00000'
            begin
                insert into @originlanes
                select distinct laneid
                from   core_lanelocation as cll
                where  cll.isorigin = 1
                       and ((cll.type = 2
                             and cll.citycode = @ll_ocity)
                            or (cll.type = 5
                                and cll.stateabbr in (select city.cty_state
                                                      from   city
                                                      where  city.cty_code = @ll_ocity))
                            or (cll.type = 3
                                and cll.zippart = @ls_ozip)
                            or (cll.type = 3
                                and cll.zippart = SUBSTRING(@ls_ozip, 1, 3)));
            end
        else
            begin
                insert into @originlanes
                select distinct laneid
                from   core_lanelocation as cll
                where  cll.isorigin = 1
                       and ((cll.type = 2
                             and cll.citycode = @ll_ocity)
                            or (cll.type = 5
                                and cll.stateabbr in (select city.cty_state
                                                      from   city
                                                      where  city.cty_code = @ll_ocity)));
            end
    end
if @ll_ocity > 0
   and @oradius > 0
    begin
        insert into @originlanes
        select distinct laneid
        from   core_lanelocation as cll
        where  cll.isorigin = 1
               and ((cll.type = 2
                     and cll.citycode in (select cty_code
                                          from   @temporigin))
                    or (cll.type = 5
                        and cll.stateabbr in (select cty_state
                                              from   city
                                              where  cty_code = @ll_ocity))
                    or (cll.type = 3
                        and cll.zippart in (select cty_zip
                                            from   @temporigin
                                            where  cty_zip is not null
                                                   and cty_zip <> ''
                                                   and cty_zip <> '00000'))
                    or (cll.type = 3
                        and cll.zippart in (select SUBSTRING(cty_zip, 1, 3)
                                            from   @temporigin
                                            where  cty_zip is not null
                                                   and cty_zip <> ''
                                                   and cty_zip <> '00000')));
    end
if @ll_ostates > 0
    begin
        insert into @originlanes
        select distinct laneid
        from   core_lanelocation as cll
        where  cll.isorigin = 1
               and ((cll.type = 5
                     and cll.stateabbr in (select origin_state
                                           from   @origin_states))
                    or (cll.type = 2
                        and cll.citycode in (select city.cty_code
                                             from   city
                                             where  city.cty_state in (select origin_state
                                                                       from   @origin_states)))
                    or (cll.type = 3
                        and cll.zippart in (select city.cty_zip
                                            from   city
                                            where  city.cty_state in (select origin_state
                                                                      from   @origin_states)))
                    or (cll.type = 3
                        and cll.zippart in (select SUBSTRING(city.cty_zip, 1, 3)
                                            from   city
                                            where  city.cty_state in (select origin_state
                                                                      from   @origin_states))));
    end
--Set count of lanes found using the origin criteria
set @ll_lanescount = 0;
select @ll_lanescount = COUNT(*)
from   @originlanes;
--Find lanes using the destination criteria.  If origin lanes were already found using the 
--origin criteria, find lanes with the destination criteria and join to the origin lanes.
if @ll_dcity > 0
   and @dradius = 0
    begin
        if @ls_dzip is not null
           and @ls_dzip <> ''
           and @ls_dzip <> '00000'
            begin
                if @ll_lanescount = 0
                    begin
                        insert into @lanes
                        select cll.laneid
                        from   core_lanelocation as cll
                        where  cll.isorigin = 2 and cll.type = 2 and cll.citycode = @ll_dcity
                        UNION
                        select cll.laneid
                        from   core_lanelocation as cll inner join city on cll.stateabbr = cty_state
                        where  cll.isorigin = 2 and cll.type = 5 and cll.citycode = @ll_dcity
                        UNION
                        select cll.laneid
                        from   core_lanelocation as cll
                        where  cll.isorigin = 2 and cll.type = 3 and cll.zippart = @ls_dzip
                        UNION
                        select cll.laneid
                        from   core_lanelocation as cll
                        where  cll.isorigin = 2 and cll.type = 3 and cll.zippart = SUBSTRING(@ls_dzip, 1, 3)
                   
                    end
                else
                    begin
                        insert into @lanes
                        select cll.laneid
                        from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
                        where  cll.isorigin = 2 and cll.type = 2 and cll.citycode = @ll_dcity
                        UNION
                        select cll.laneid
                        from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
								inner join city on cll.stateabbr = city.cty_state
                        where  cll.isorigin = 2 and cll.type = 5 and city.cty_code = @ll_dcity
                        UNION        
						select cll.laneid
                        from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
                        where  cll.isorigin = 2 and cll.type = 3 and cll.zippart = @ls_dzip
                        UNION
                        select cll.laneid
                        from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
                        where  cll.isorigin = 2 and cll.type = 3 and cll.zippart = SUBSTRING(@ls_dzip, 1, 3);
            
                    end
            end
        else
            begin
                if @ll_lanescount = 0
                    begin
                        insert into @lanes
                        select cll.laneid
                        from   core_lanelocation as cll
                        where  cll.isorigin = 2 and cll.type = 2 and cll.citycode = @ll_dcity
                        UNION
                        select cll.laneid
                        from   core_lanelocation as cll inner join city on cll.stateabbr = city.cty_state
                        where  cll.isorigin = 2 and cll.type = 5 and city.cty_code = @ll_dcity;
                    end
                else
                    begin
                        insert into @lanes
                        select cll.laneid
                        from   core_lanelocation as cll
                               inner join @originlanes o on cll.laneid = o.laneid
                        where  cll.isorigin = 2 and cll.type = 2 and cll.citycode = @ll_dcity
                        UNION
                        select cll.laneid
                        from   core_lanelocation as cll
                               inner join @originlanes o on cll.laneid = o.laneid
                               inner join city on cll.stateabbr = city.cty_state
                        where  cll.isorigin = 2 and cll.type = 5 and city.cty_code = @ll_dcity;
                    end
            end
    end
if @ll_dcity > 0
   and @dradius > 0
    begin
        if @ll_lanescount = 0
            begin
                insert into @lanes
                select cll.laneid
                from   core_lanelocation as cll inner join @tempdest td on cll.citycode = td.cty_code
                where  cll.isorigin = 2  and cll.type = 2
                UNION
                select cll.laneid
                from   core_lanelocation as cll inner join city c on cll.stateabbr = c.cty_state
                where  cll.isorigin = 2 and cty_code = @ll_dcity and cll.type = 5
                UNION
                select cll.laneid
                from   core_lanelocation as cll inner join @tempdest td on cll.zippart = td.cty_zip
                where  cll.isorigin = 2 and cll.type = 3 and td.cty_zip is not null
                                                           and td.cty_zip <> ''
                                                           and td.cty_zip <> '00000' 
                UNION 
                select cll.laneid
                from   core_lanelocation as cll inner join @tempdest td on cll.zippart = SUBSTRING(cty_zip, 1, 3)
                where  cll.isorigin = 2 and cll.type = 3 and td.cty_zip is not null
                                                           and td.cty_zip <> ''
                                                           and td.cty_zip <> '00000';
            end
        else
            begin
                insert into @lanes
                select cll.laneid
                from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
                inner join @tempdest td on cll.citycode = td.cty_code
                where  cll.isorigin = 2 and cll.type = 2
				UNION                                  
                select cll.laneid
                from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
                inner join city c on cll.stateabbr = c.cty_state
                where  cll.isorigin = 2 and cty_code = @ll_dcity and cll.type = 5
				UNION                                     
                select cll.laneid
                from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
                inner join @tempdest td on cll.zippart = td.cty_zip
                where  cll.isorigin = 2 and cll.type = 3 and cty_zip is not null
                                                           and cty_zip <> ''
                                                           and cty_zip <> '00000'
                UNION                                           
                select cll.laneid
                from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
                inner join @tempdest td on cll.zippart = SUBSTRING(cty_zip, 1, 3)
                where  cll.isorigin = 2 and cll.type = 3 and cty_zip is not null
                                                           and cty_zip <> ''
                                                           and cty_zip <> '00000';
            end
    end
if @ll_dstates > 0
    begin
        if @ll_lanescount = 0
            begin
                insert into @lanes
                select cll.laneid
                from   core_lanelocation as cll inner join @destination_states on cll.stateabbr = destination_state
                where  cll.isorigin = 2 and cll.type = 5
                UNION                                 
				select cll.laneid
				from   core_lanelocation as cll inner join city on cll.citycode = city.cty_code
				inner join @destination_states d on city.cty_state = d.destination_state
				where  cll.isorigin = 2 and cll.type = 2
				UNION
                select cll.laneid
				from   core_lanelocation as cll inner join city on cll.zippart = city.cty_zip
				inner join @destination_states d on city.cty_state = d.destination_state
				where  cll.isorigin = 2 and cll.type = 3
				UNION                                                            
                select cll.laneid
				from   core_lanelocation as cll inner join city on cll.zippart = SUBSTRING(city.cty_zip, 1, 3)
				inner join @destination_states d on city.cty_state = d.destination_state
				where  cll.isorigin = 2 and cll.type = 3;
            end
        else
            begin
                insert into @lanes
                select cll.laneid
                from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
                inner join @destination_states d on cll.stateabbr = d.destination_state
                where  cll.isorigin = 2 and cll.type = 5                                 
                UNION
                select cll.laneid
                from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
                inner join city on cll.citycode = city.cty_code
                inner join @destination_states d on city.cty_state = d.destination_state
                where  cll.isorigin = 2 and cll.type = 2
                UNION
                select cll.laneid
                from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
                inner join city on cll.zippart = city.cty_zip
                inner join @destination_states d on city.cty_state = d.destination_state
                where  cll.isorigin = 2 and cll.type = 3
                UNION
                select cll.laneid
                from   core_lanelocation as cll inner join @originlanes o on cll.laneid = o.laneid
                inner join city on cll.zippart = SUBSTRING(city.cty_zip, 1, 3)
                inner join @destination_states d on city.cty_state = d.destination_state
                where  cll.isorigin = 2 and cll.type = 3;
            end
    end
--If origin lanes were found using the origin criteria and no destination criteria was entered,
--move the rows from the @originlanes table into the @lanes table.
if @ll_lanescount > 0
   and @ll_dcity = 0
   and @ll_dstates = 0
    begin
        insert into @lanes
        select laneid
        from   @originlanes;
    end
--If no origin or destination criteria was entered, load all distinct lanes into the @lanes table.
if @ll_ocity = 0
   and @ll_ostates = 0
   and @ll_dcity = 0
   and @ll_dstates = 0
    begin
        insert into @lanes
        select distinct laneid
        from   core_lanelocation;
    end
--Find all of the distinct carriers that are assigned to the lanes from the @lanes table.
insert into @lanecarriers
select distinct car_id
from   core_carrierlanecommitment
       inner join
       @lanes l
       on core_carrierlanecommitment.laneid = l.laneid;

--Update @temp1's preferred_lane column for the carrier found in @lanecarriers
update  @temp1
    set preferred_lane = 'Y'
where   trk_carrier in (select car_id
                               from   @lanecarriers);
--Insert a row into @temp1 for carriers not already in @temp1 from @lanecarriers
--PTS51809 MBR 04/27/10 Added carrierhistory columns
insert into @temp2 (trk_carrier, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, orig_domicile, dest_domicile, haspaymenthist, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
select carrier.car_id,
       ISNULL(carrier.car_name, ''),
       ISNULL(carrier.car_address1, ''),
       ISNULL(carrier.car_address2, ''),
       ISNULL(carrier.car_scac, ''),
       ISNULL(carrier.car_Phone1, ''),
       ISNULL(carrier.car_Phone2, ''),
       ISNULL(carrier.car_contact, ''),
       ISNULL(carrier.car_phone3, ''),
       ISNULL(carrier.car_email, ''),
       ISNULL(carrier.car_currency, ''),
       (select name
        from   labelfile with (nolock)
        where  labeldefinition = 'CarrierServiceRating'
               and abbr = carrier.car_rating),
	   @cartypes1,
	   @cartypes2,
	   @cartypes3,
	   @cartypes4,
       carrier.car_type1,
       carrier.car_type2,
       carrier.car_type3,
       carrier.car_type4,
       city.cty_nmstct,
       carrier.cty_code,
       city.cty_state,
       'N',
       'N',
       'N',
       'N',
       'Y',
       --PTS51809 MBR 04/27/10
       ISNULL(carrierhistory.crh_total, 0),
       ISNULL(carrierhistory.crh_ontime, 0),
       ISNULL(carrierhistory.crh_percent, 0),
       ISNULL(carrierhistory.crh_avefuel, 0),
       ISNULL(carrierhistory.crh_avetotal, 0),
       ISNULL(carrierhistory.crh_aveacc, 0)
from   @lanecarriers lc inner join carrier on lc.car_id = carrier.car_id
       inner join city with (nolock) on carrier.cty_code = city.cty_code
       inner join @temp_filteredcarriers tf on lc.car_id = tf.fcr_carrier
       left outer join carrierhistory with (nolock) on lc.car_id = carrierhistory.crh_carrier
where  lc.car_id not in (select trk_carrier from @temp1);

--PTS51809 MBR 04/27/10 Added carrierhistory columns
insert into @temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, dest_domicile, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
select trk_carrier,
       tar_number,
       car_name,
       car_address1,
       car_address2,
       car_scac,
       car_phone1,
       car_phone2,
       car_contact,
       car_phone3,
       car_email,
       car_currency,
       car_rating,
       cartype1_t,
       cartype2_t,
       cartype3_t,
       cartype4_t,
       car_type1,
       car_type2,
       car_type3,
       car_type4,
       cty_nmstct,
       cty_code,
       cty_state,
       haspaymenthist,
       orig_domicile,
       dest_domicile,
       rateonfileorigin,
       preferred_lane,
       crh_total,
       crh_ontime,
       crh_percent,
       crh_avefuel,
       crh_avetotal,
       crh_aveacc
from   @temp2;
delete @temp2;

if @ll_ocity > 0
    begin
        update  @temp1
            set orig_domicile = 'Y'
        where   ((@oradius = 0
                  and cty_code = @ll_ocity)
                 or (@oradius > 0
                     and cty_code in (select cty_code
                                             from   @temporigin)));
        --PTS 49964 JJF 20091221 sqlserver2008 workaround
        --INSERT INTO @temp1 (trk_carrier, car_name, car_address1, car_address2,
        --PTS51809 MBR 04/27/10 Added carrierhistory columns
        
        if @oradius = 0
        begin
			insert into @temp2 (trk_carrier, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, orig_domicile, dest_domicile, haspaymenthist, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
			select carrier.car_id,
				   ISNULL(carrier.car_name, ''),
				   ISNULL(carrier.car_address1, ''),
				   ISNULL(carrier.car_address2, ''),
				   ISNULL(carrier.car_scac, ''),
				   ISNULL(carrier.car_Phone1, ''),
				   ISNULL(carrier.car_Phone2, ''),
				   ISNULL(carrier.car_contact, ''),
				   ISNULL(carrier.car_phone3, ''),
				   ISNULL(carrier.car_email, ''),
				   ISNULL(carrier.car_currency, ''),
				   (select name
					from   labelfile with (nolock)
					where  labeldefinition = 'CarrierServiceRating'
						   and abbr = carrier.car_rating),
				   @cartypes1,
				   @cartypes2,
				   @cartypes3,
				   @cartypes4,
				   carrier.car_type1,
				   carrier.car_type2,
				   carrier.car_type3,
				   carrier.car_type4,
				   city.cty_nmstct,
				   carrier.cty_code,
				   city.cty_state,
				   'Y',
				   'N',
				   'N',
				   'N',
				   'N',
				   --PTS51809 MBR 04/27/10
				   ISNULL(carrierhistory.crh_total, 0),
				   ISNULL(carrierhistory.crh_ontime, 0),
				   ISNULL(carrierhistory.crh_percent, 0),
				   ISNULL(carrierhistory.crh_avefuel, 0),
				   ISNULL(carrierhistory.crh_avetotal, 0),
				   ISNULL(carrierhistory.crh_aveacc, 0)
			from   carrier inner join city  on carrier.cty_code = city.cty_code
			inner join @temp_filteredcarriers tf on carrier.car_id = tf.fcr_carrier
			left outer join carrierhistory on carrier.car_id = carrierhistory.crh_carrier
			where  carrier.cty_code = @ll_ocity and
			carrier.car_id not in (select trk_carrier from @temp1)
        end
 else if @oradius > 0
		begin
			insert into @temp2 (trk_carrier, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, orig_domicile, dest_domicile, haspaymenthist, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
			select carrier.car_id,
				   ISNULL(carrier.car_name, ''),
				   ISNULL(carrier.car_address1, ''),
				   ISNULL(carrier.car_address2, ''),
				   ISNULL(carrier.car_scac, ''),
				   ISNULL(carrier.car_Phone1, ''),
				   ISNULL(carrier.car_Phone2, ''),
				   ISNULL(carrier.car_contact, ''),
				   ISNULL(carrier.car_phone3, ''),
				   ISNULL(carrier.car_email, ''),
				   ISNULL(carrier.car_currency, ''),
				   (select name
					from   labelfile with (nolock)
					where  labeldefinition = 'CarrierServiceRating'
						   and abbr = carrier.car_rating),
				   @cartypes1,
				   @cartypes2,
				   @cartypes3,
				   @cartypes4,
				   carrier.car_type1,
				   carrier.car_type2,
				   carrier.car_type3,
				   carrier.car_type4,
				   city.cty_nmstct,
				   carrier.cty_code,
				   city.cty_state,
				   'Y',
				   'N',
				   'N',
				   'N',
				   'N',
				   --PTS51809 MBR 04/27/10
				   ISNULL(carrierhistory.crh_total, 0),
				   ISNULL(carrierhistory.crh_ontime, 0),
				   ISNULL(carrierhistory.crh_percent, 0),
				   ISNULL(carrierhistory.crh_avefuel, 0),
				   ISNULL(carrierhistory.crh_avetotal, 0),
				   ISNULL(carrierhistory.crh_aveacc, 0)
			from   carrier inner join city  on carrier.cty_code = city.cty_code
			inner join @temp_filteredcarriers tf on carrier.car_id = tf.fcr_carrier
			inner join @temporigin tor on carrier.cty_code = tor.cty_code
			left join carrierhistory on carrier.car_id = carrierhistory.crh_carrier
			left join @temp1 t1 on carrier.car_id = t1.trk_carrier
			where t1.trk_carrier is null
			--where carrier.car_id not in (select trk_carrier from @temp1)
        end
                                
        --PTS 49964 JJF 20091221 sqlserver2008 workaround
        --PTS51809 MBR 04/27/10 Added carrierhistory columns
        insert into @temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, dest_domicile, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
        select trk_carrier,
               tar_number,
               car_name,
               car_address1,
               car_address2,
               car_scac,
               car_phone1,
               car_phone2,
               car_contact,
               car_phone3,
               car_email,
               car_currency,
               car_rating,
               cartype1_t,
               cartype2_t,
               cartype3_t,
               cartype4_t,
               car_type1,
               car_type2,
               car_type3,
               car_type4,
               cty_nmstct,
               cty_code,
               cty_state,
               haspaymenthist,
               orig_domicile,
               dest_domicile,
               rateonfileorigin,
               preferred_lane,
               crh_total,
               crh_ontime,
               crh_percent,
               crh_avefuel,
               crh_avetotal,
               crh_aveacc
        from   @temp2;
        delete @temp2;
    --PTS 49964 JJF 20091221 sqlserver2008 workaround
    end
if @ll_ostates > 0
    begin
        update  @temp1
            set orig_domicile = 'Y'
        where   cty_state in (select origin_state
                                     from   @origin_states);
        --PTS 49964 JJF 20091221 sqlserver2008 workaround
        --INSERT INTO @temp1 (trk_carrier, car_name, car_address1, car_address2,
        --PTS51809 MBR 04/27/10 Added carrierhistory columns
        insert into @temp2 (trk_carrier, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, orig_domicile, dest_domicile, haspaymenthist, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
        select carrier.car_id,
               ISNULL(carrier.car_name, ''),
               ISNULL(carrier.car_address1, ''),
               ISNULL(carrier.car_address2, ''),
               ISNULL(carrier.car_scac, ''),
               ISNULL(carrier.car_Phone1, ''),
               ISNULL(carrier.car_Phone2, ''),
               ISNULL(carrier.car_contact, ''),
               ISNULL(carrier.car_phone3, ''),
               ISNULL(carrier.car_email, ''),
               ISNULL(carrier.car_currency, ''),
               (select name
                from   labelfile with (nolock)
                where  labeldefinition = 'CarrierServiceRating'
                       and abbr = carrier.car_rating),
			   @cartypes1,
			   @cartypes2,
			   @cartypes3,
			   @cartypes4,
               carrier.car_type1,
               carrier.car_type2,
               carrier.car_type3,
               carrier.car_type4,
               city.cty_nmstct,
               carrier.cty_code,
               city.cty_state,
               'Y',
               'N',
               'N',
               'N',
               'N',
               --PTS51809 MBR 04/27/10
               ISNULL(carrierhistory.crh_total, 0),
               ISNULL(carrierhistory.crh_ontime, 0),
               ISNULL(carrierhistory.crh_percent, 0),
               ISNULL(carrierhistory.crh_avefuel, 0),
               ISNULL(carrierhistory.crh_avetotal, 0),
               ISNULL(carrierhistory.crh_aveacc, 0)
        from   carrier 
               inner join
               city 
               on carrier.cty_code = city.cty_code
               inner join @origin_states os on city.cty_state = os.origin_state
			inner join @temp_filteredcarriers tf on carrier.car_id = tf.fcr_carrier
               left outer join
               carrierhistory with (nolock)
               on carrier.car_id = carrierhistory.crh_carrier
        where  carrier.car_id not in (select trk_carrier
                                      from   @temp1);
                                      
        --PTS 49964 JJF 20091221 sqlserver2008 workaround
        --PTS51809 MBR 04/27/10 Added carrierhistory columns
        insert into @temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, dest_domicile, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
        select trk_carrier,
               tar_number,
               car_name,
               car_address1,
               car_address2,
               car_scac,
               car_phone1,
               car_phone2,
               car_contact,
               car_phone3,
               car_email,
               car_currency,
               car_rating,
               cartype1_t,
               cartype2_t,
               cartype3_t,
               cartype4_t,
               car_type1,
               car_type2,
               car_type3,
               car_type4,
               cty_nmstct,
               cty_code,
               cty_state,
               haspaymenthist,
               orig_domicile,
               dest_domicile,
               rateonfileorigin,
               preferred_lane,
               crh_total,
               crh_ontime,
               crh_percent,
               crh_avefuel,
               crh_avetotal,
               crh_aveacc
        from   @temp2;
        delete @temp2;
    --END PTS 49964 JJF 20091221 sqlserver2008 workaround
    end
if @ll_dcity > 0
    begin
        update  @temp1
            set dest_domicile = 'Y'
        where   ((@dradius = 0
                  and cty_code = @ll_dcity)
                 or (@dradius > 0
                     and cty_code in (select cty_code
                                             from   @tempdest)));
        --PTS 49964 JJF 20091221 sqlserver2008 workaround
        --INSERT INTO @temp1 (trk_carrier, car_name, car_address1, car_address2,
        --PTS51809 MBR 04/27/10 Added carrierhistory columns
        
        if @dradius = 0
        begin
			insert into @temp2 (trk_carrier, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, dest_domicile, orig_domicile, haspaymenthist, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
			select carrier.car_id,
				   ISNULL(carrier.car_name, ''),
				   ISNULL(carrier.car_address1, ''),
				   ISNULL(carrier.car_address2, ''),
				   ISNULL(carrier.car_scac, ''),
				   ISNULL(carrier.car_Phone1, ''),
				   ISNULL(carrier.car_Phone2, ''),
				   ISNULL(carrier.car_contact, ''),
				   ISNULL(carrier.car_phone3, ''),
				   ISNULL(carrier.car_email, ''),
				   ISNULL(carrier.car_currency, ''),
				   (select name
					from   labelfile with (nolock)
					where  labeldefinition = 'CarrierServiceRating'
						   and abbr = carrier.car_rating),
				   @cartypes1,
				   @cartypes2,
				   @cartypes3,
				   @cartypes4,
				   carrier.car_type1,
				   carrier.car_type2,
				   carrier.car_type3,
				   carrier.car_type4,
				   city.cty_nmstct,
				   carrier.cty_code,
				   city.cty_state,
				   'Y',
				   'N',
				   'N',
				   'N',
				   'N',
				   --PTS51809 MBR 04/27/10
				   ISNULL(carrierhistory.crh_total, 0),
				   ISNULL(carrierhistory.crh_ontime, 0),
				   ISNULL(carrierhistory.crh_percent, 0),
				   ISNULL(carrierhistory.crh_avefuel, 0),
				   ISNULL(carrierhistory.crh_avetotal, 0),
				   ISNULL(carrierhistory.crh_aveacc, 0)
			from   carrier 
				   inner join
				   city 
				   on carrier.cty_code = city.cty_code
				   inner join @temp_filteredcarriers tf on carrier.car_id = tf.fcr_carrier
				   left outer join
				   carrierhistory 
				   on carrier.car_id = carrierhistory.crh_carrier
			where  carrier.cty_code = @ll_dcity and
			carrier.car_id not in (select trk_carrier
											  from   @temp1)
	
        end
  else if @dradius > 0      
   begin
			insert into @temp2 (trk_carrier, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, dest_domicile, orig_domicile, haspaymenthist, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
			select carrier.car_id,
				   ISNULL(carrier.car_name, ''),
				   ISNULL(carrier.car_address1, ''),
				   ISNULL(carrier.car_address2, ''),
				   ISNULL(carrier.car_scac, ''),
				   ISNULL(carrier.car_Phone1, ''),
				   ISNULL(carrier.car_Phone2, ''),
				   ISNULL(carrier.car_contact, ''),
				   ISNULL(carrier.car_phone3, ''),
				   ISNULL(carrier.car_email, ''),
				   ISNULL(carrier.car_currency, ''),
				   (select name
					from   labelfile with (nolock)
					where  labeldefinition = 'CarrierServiceRating'
						   and abbr = carrier.car_rating),
				   @cartypes1,
				   @cartypes2,
				   @cartypes3,
				   @cartypes4,
				   carrier.car_type1,
				   carrier.car_type2,
				   carrier.car_type3,
				   carrier.car_type4,
				   city.cty_nmstct,
				   carrier.cty_code,
				   city.cty_state,
				   'Y',
				   'N',
				   'N',
				   'N',
				   'N',
				   --PTS51809 MBR 04/27/10
				   ISNULL(carrierhistory.crh_total, 0),
				   ISNULL(carrierhistory.crh_ontime, 0),
				   ISNULL(carrierhistory.crh_percent, 0),
				   ISNULL(carrierhistory.crh_avefuel, 0),
				   ISNULL(carrierhistory.crh_avetotal, 0),
				   ISNULL(carrierhistory.crh_aveacc, 0)
				   from   carrier inner join city on carrier.cty_code = city.cty_code
				   inner join @temp_filteredcarriers tf on carrier.car_id = tf.fcr_carrier
				   left join carrierhistory on carrier.car_id = carrierhistory.crh_carrier
				   inner join @tempdest td on carrier.cty_code = td.cty_code
				   left join @temp1 t1 on carrier.car_id = t1.trk_carrier
				   where t1.trk_carrier is null
				   --where carrier.car_id not in (select trk_carrier from @temp1)
	    end
											  
                                          
        --PTS 49964 JJF 20091221 sqlserver2008 workaround
        --PTS51809 MBR 04/27/10 Added carrierhistory columns
        insert into @temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, dest_domicile, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
        select trk_carrier,
               tar_number,
               car_name,
               car_address1,
               car_address2,
               car_scac,
               car_phone1,
               car_phone2,
               car_contact,
               car_phone3,
               car_email,
               car_currency,
               car_rating,
               cartype1_t,
               cartype2_t,
               cartype3_t,
               cartype4_t,
               car_type1,
               car_type2,
               car_type3,
               car_type4,
               cty_nmstct,
               cty_code,
               cty_state,
               haspaymenthist,
               orig_domicile,
               dest_domicile,
               rateonfileorigin,
               preferred_lane,
               crh_total,
               crh_ontime,
               crh_percent,
               crh_avefuel,
               crh_avetotal,
               crh_aveacc
        from   @temp2;
        delete @temp2;
    --END PTS 49964 JJF 20091221 sqlserver2008 workaround
    end
if @ll_dstates > 0
    begin
        update  @temp1
            set dest_domicile = 'Y'
        where   cty_state in (select destination_state
                                     from   @destination_states);
        --PTS 49964 JJF 20091221 sqlserver2008 workaround
        --INSERT INTO @temp1 (trk_carrier, car_name, car_address1, car_address2,
        --PTS51809 MBR 04/27/10 Added carrierhistory columns
        insert into @temp2 (trk_carrier, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, dest_domicile, orig_domicile, haspaymenthist, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
        select carrier.car_id,
               ISNULL(carrier.car_name, ''),
               ISNULL(carrier.car_address1, ''),
               ISNULL(carrier.car_address2, ''),
               ISNULL(carrier.car_scac, ''),
               ISNULL(carrier.car_Phone1, ''),
               ISNULL(carrier.car_Phone2, ''),
               ISNULL(carrier.car_contact, ''),
               ISNULL(carrier.car_phone3, ''),
               ISNULL(carrier.car_email, ''),
               ISNULL(carrier.car_currency, ''),
               (select name
                from   labelfile with (nolock)
                where  labeldefinition = 'CarrierServiceRating'
                       and abbr = carrier.car_rating),
			   @cartypes1,
			   @cartypes2,
			   @cartypes3,
			   @cartypes4,
               carrier.car_type1,
               carrier.car_type2,
               carrier.car_type3,
               carrier.car_type4,
               city.cty_nmstct,
               carrier.cty_code,
               city.cty_state,
               'Y',
               'N',
               'N',
               'N',
               'N',
               --PTS51809 MBR 04/27/10
               ISNULL(carrierhistory.crh_total, 0),
               ISNULL(carrierhistory.crh_ontime, 0),
               ISNULL(carrierhistory.crh_percent, 0),
               ISNULL(carrierhistory.crh_avefuel, 0),
               ISNULL(carrierhistory.crh_avetotal, 0),
               ISNULL(carrierhistory.crh_aveacc, 0)
        from   carrier with (nolock)
               inner join
               city with (nolock)
               on carrier.cty_code = city.cty_code
               inner join @destination_states ds on city.cty_state = ds.destination_state
			   inner join @temp_filteredcarriers tf on carrier.car_id = tf.fcr_carrier
               left outer join
               carrierhistory with (nolock)
               on carrier.car_id = carrierhistory.crh_carrier
        where  carrier.car_id not in (select trk_carrier
                                      from   @temp1);
                                      
        --PTS 49964 JJF 20091221 sqlserver2008 workaround
        --PTS51809 MBR 04/27/10 Added carrierhistory columns
        insert into @temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, dest_domicile, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
        select trk_carrier,
               tar_number,
               car_name,
               car_address1,
               car_address2,
               car_scac,
               car_phone1,
               car_phone2,
               car_contact,
               car_phone3,
               car_email,
               car_currency,
               car_rating,
               cartype1_t,
               cartype2_t,
               cartype3_t,
               cartype4_t,
               car_type1,
               car_type2,
               car_type3,
               car_type4,
               cty_nmstct,
               cty_code,
               cty_state,
               haspaymenthist,
               orig_domicile,
               dest_domicile,
               rateonfileorigin,
               preferred_lane,
               crh_total,
               crh_ontime,
               crh_percent,
               crh_avefuel,
               crh_avetotal,
               crh_aveacc
        from   @temp2;
        delete @temp2;
    --END PTS 49964 JJF 20091221 sqlserver2008 workaround
    end
--If there is no origin or destination criteria, get all carriers from @temp_filteredcarriers
--that were not already inserted into @temp1 because of history detail.
if @ll_ocity = 0
   and @ll_ostates = 0
   and @ll_dcity = 0
   and @ll_dstates = 0
    begin
        --PTS 49964 JJF 20091221 sqlserver2008 workaround
        --INSERT INTO @temp1 (trk_carrier, car_name, car_address1, car_address2,
        --PTS51809 MBR 04/27/10 Added carrierhistory columns
        insert into @temp2 (trk_carrier, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, dest_domicile, orig_domicile, haspaymenthist, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
        select carrier.car_id,
               ISNULL(carrier.car_name, ''),
               ISNULL(carrier.car_address1, ''),
               ISNULL(carrier.car_address2, ''),
               ISNULL(carrier.car_scac, ''),
               ISNULL(carrier.car_Phone1, ''),
               ISNULL(carrier.car_Phone2, ''),
               ISNULL(carrier.car_contact, ''),
               ISNULL(carrier.car_phone3, ''),
               ISNULL(carrier.car_email, ''),
               ISNULL(carrier.car_currency, ''),
               (select name
                from   labelfile with (nolock)
                where  labeldefinition = 'CarrierServiceRating'
                       and abbr = carrier.car_rating),
			   @cartypes1,
			   @cartypes2,
			   @cartypes3,
			   @cartypes4,
               carrier.car_type1,
               carrier.car_type2,
               carrier.car_type3,
               carrier.car_type4,
               city.cty_nmstct,
               carrier.cty_code,
               city.cty_state,
               'N',
               'N',
               'N',
               'N',
               'N',
               --PTS51809 MBR 04/27/10
               ISNULL(carrierhistory.crh_total, 0),
               ISNULL(carrierhistory.crh_ontime, 0),
               ISNULL(carrierhistory.crh_percent, 0),
               ISNULL(carrierhistory.crh_avefuel, 0),
               ISNULL(carrierhistory.crh_avetotal, 0),
               ISNULL(carrierhistory.crh_aveacc, 0)
        from   carrier 
               inner join
               city  
               on carrier.cty_code = city.cty_code
               inner join @temp_filteredcarriers tf on carrier.car_id = tf.fcr_carrier
               left outer join
               carrierhistory with (nolock)
               on carrier.car_id = carrierhistory.crh_carrier
        where  carrier.car_id not in (select trk_carrier
                                      from   @temp1);
                                      
        --PTS 49964 JJF 20091221 sqlserver2008 workaround
        --PTS51809 MBR 04/27/10 Added carrierhistory columns
        insert into @temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2, car_scac, car_phone1, car_phone2, car_contact, car_phone3, car_email, car_currency, car_rating, cartype1_t, cartype2_t, cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, dest_domicile, rateonfileorigin, preferred_lane, crh_total, crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
        select trk_carrier,
               tar_number,
               car_name,
               car_address1,
               car_address2,
               car_scac,
               car_phone1,
               car_phone2,
               car_contact,
               car_phone3,
               car_email,
               car_currency,
               car_rating,
               cartype1_t,
               cartype2_t,
               cartype3_t,
               cartype4_t,
               car_type1,
               car_type2,
               car_type3,
               car_type4,
               cty_nmstct,
               cty_code,
               cty_state,
               haspaymenthist,
               orig_domicile,
               dest_domicile,
               rateonfileorigin,
               preferred_lane,
               crh_total,
               crh_ontime,
               crh_percent,
               crh_avefuel,
               crh_avetotal,
               crh_aveacc
        from   @temp2;
        delete @temp2;
    --END PTS 49964 JJF 20091221 sqlserver2008 workaround
    end
update  @temp1
    set car_exp1date = car_exp1_date,
        car_exp2date = car_exp2_date
from    carrier with (nolock) inner join @temp1 t
on   carrier.car_id = t.trk_carrier;

update  @temp1
    set pri1expsoon = case 
when car_exp1date <= dateadd(dd, @expdate, getdate()) then 1 else 0 
end,
        pri2expsoon = case 
when car_exp2date <= dateadd(dd, @expdate, getdate()) then 1 else 0 
end;
--50142 pmill need to check expirations currently in effect also   
--PTS 53571 KMM/JJF 20100818

update  @temp1
    set exp_priority1 = (select count(0)
                         from   expiration with (nolock) inner join @temp1 t on exp_id = trk_carrier
                         where  exp_idtype = 'CAR'
                                and exp_priority = 1
                                and exp_completed = 'N'
                                and @stp_departure_dt > exp_expirationdate);
update  @temp1
    set exp_priority2 = (select count(0)
                         from   expiration with (nolock) inner join @temp1 t on exp_id = trk_carrier
                         where  exp_idtype = 'CAR'
                                and exp_priority > 1
                                and exp_completed = 'N'
                                and @stp_departure_dt > exp_expirationdate);
     
 
--PTS 49332 JJF 20091008  
UPDATE @temp1  
SET distance_to_origin = dbo.tmw_airdistance_fn(@orig_lat, @orig_long, fcr_dom_lat, fcr_dom_long),  
 distance_to_destination = dbo.tmw_airdistance_fn(@dest_lat, @dest_long, fcr_dom_lat, fcr_dom_long)   
FROM @temp1 t INNER JOIN @temp_filteredcarriers fcr on t.trk_carrier = fcr.fcr_carrier  
--END PTS 49332 JJF 20091008  
      
--END PTS 49332 JJF 20091008
--PTS 51918 JJF 20110210
declare @AssetsToInclude as varchar (60);
declare @DisplayQualifications as varchar (1);
declare @Delimiter as varchar (1);
declare @IncludeAssetPrefix as int;
declare @IncludeLabelName as int;
select @DisplayQualifications = ISNULL(gi_string1, 'N'),
       @AssetsToInclude = ',' + ISNULL(gi_string2, '') + ',',
       @Delimiter = ISNULL(gi_string3, '*'),
       @IncludeAssetPrefix = ISNULL(gi_integer1, 0),
       @IncludeLabelName = ISNULL(gi_integer2, 0)
from   generalinfo
where  gi_name = 'QualListCarrierPlan';
if @DisplayQualifications = 'Y'
    begin
        if @AssetsToInclude = ',,'
            begin
                set @AssetsToInclude = ',CAR,';
            end
        update  @temp1
            set qualification_list_drv = dbo.QualificationsToCSV_fn(null, null, null, null, null, case CHARINDEX(',CAR,', @AssetsToInclude) 
when 0 then 'UNKNOWN' else trk_carrier 
end, case CHARINDEX(',CAR,', @AssetsToInclude) 
when 0 then 'UNKNOWN' else trk_carrier 
end, null, null, last_used_date, last_used_date, @IncludeAssetPrefix, @IncludeLabelName, @Delimiter),
                qualification_list_trc = dbo.QualificationsToCSV_fn(null, null, null, null, null, null, null, case CHARINDEX(',CAR,', @AssetsToInclude) 
when 0 then 'UNKNOWN' else trk_carrier 
end, null, last_used_date, last_used_date, @IncludeAssetPrefix, @IncludeLabelName, @Delimiter),
                qualification_list_trl = dbo.QualificationsToCSV_fn(null, null, null, null, null, null, null, null, case CHARINDEX(',CAR,', @AssetsToInclude) 
when 0 then 'UNKNOWN' else trk_carrier 
end, last_used_date, last_used_date, @IncludeAssetPrefix, @IncludeLabelName, @Delimiter)
        from    @temp1;
    end
--END PTS 51918 JJF 20110210
--PTS 53571 KMM/JJF 20100818 - DON'T RETURN RESULTS IF THERE IS ZERO CRITERIA
ENDPROC:
select ISNULL(trk_number, '') as trk_number,
       ISNULL(tar_number, 0) as tar_number,
       ISNULL(tar_rate, 0) as tar_rate,
       ISNULL(trk_carrier, '') as trk_carrier,
       ISNULL(Crh_Total, 0) as crh_total,
       ISNULL(Crh_OnTime, 0) as crh_ontime,
       ISNULL(cht_itemcode, '') as cht_itemcode,
       ISNULL(cht_description, '') as cht_description,
       ISNULL(crh_percent, '') as crh_percent,
       ISNULL(Crh_AveFuel, 0) as crh_avefuel,
       ISNULL(Crh_AveTotal, 0) as crh_avetotal,
       ISNULL(Crh_AveAcc, 0) as crh_aveacc,
       ISNULL(car_name, '') as car_name,
       ISNULL(car_address1, '') as car_address1,
       ISNULL(car_address2, '') as car_address2,
       ISNULL(car_scac, '') as car_scac,
       ISNULL(car_phone1, '') as car_phone1,
       ISNULL(car_phone2, '') as car_phone2,
       ISNULL(car_contact, '') as car_contact,
       ISNULL(car_phone3, '') as car_phone3,
       ISNULL(car_email, '') as car_email,
       ISNULL(car_currency, '') as car_currency,
       ISNULL(cht_currunit, '') as cht_currunit,
       ISNULL(car_rating, '') as car_rating,
       ISNULL(exp_priority1, 0) as exp_priority1,
       ISNULL(exp_priority2, 0) as exp_priority2,
       ISNULL(cty_nmstct, 0) as cty_nmstct,
       ISNULL(totalordersfiltered, 0) as totalordersfiltered,
       ISNULL(ontimeordersfiltered, 0) as ontimeordersfiltered,
       ISNULL(percentontimefiltered, 0) as percentontimefiltered,
       ISNULL(orig_domicile, '') as orig_domicile,
       ISNULL(dest_domicile, '') as dest_domicile,
       ISNULL(rateonfileorigin, '') as rateonfileorigin,
       ISNULL(rateonfiledest, '') as rateonfiledest,
       ISNULL(haspaymenthist, '') as haspaymenthist,
       ISNULL(PayHistAtOrigin, '') as PayHistAtOrigin,
       ISNULL(PayHistAtDest, '') as PayHistAtDest,
       ISNULL(MatchResult, '') as MatchResult,
       ISNULL(RatePaidAtOrigin, '') as RatePaidAtOrigin,
       ISNULL(RatePaidAtDest, '') as RatePaidAtDest,
       ISNULL(cartype1_t, 'Car Type1') as cartype1_t,
       ISNULL(cartype2_t, 'Car Type2') as cartype2_t,
       ISNULL(cartype3_t, 'Car Type3') as cartype3_t,
       ISNULL(cartype4_t, 'Car Type4') as cartype4_t,
       ISNULL(car_type1, 'UNK') as car_type1,
       ISNULL(car_type2, 'UNK') as car_type2,
       ISNULL(car_type3, 'UNK') as car_type3,
       ISNULL(car_type4, 'UNK') as car_type4,
       ISNULL(pri1expsoon, 0) as pri1expsoon,
       ISNULL(pri2expsoon, 0) as pri2expsoon,
       last_chd_id,
       --PTS 53884 JJF 20100928 set date to max so that real dates bubble to the top for sorting
       --last_used_date,
       isnull(last_used_date, '19500101') as last_used_date,
       --PTS 53884 JJF 20100928 set date to max so that real dates bubble to the top for sorting
       ISNULL(last_billed, 0) as last_billed,
       ISNULL(last_paid, 0) as last_paid,
       ISNULL(total_billed, 0) as total_billed,
       ISNULL(pay_linehaul, 0) as pay_linehaul,
       ISNULL(pay_accessorial, 0) as pay_accessorial,
       ISNULL(pay_fsc, 0) as pay_fsc,
       cty_code,
       cty_state,
       ISNULL(total_trips, 0) as total_trips,
       ISNULL(total_late, 0) as total_late,
       min_chd_id,
       ISNULL(min_billed, 0) as min_billed,
       ISNULL(min_paid, 0) as min_paid,
       max_chd_id,
       ISNULL(max_billed, 0) as max_billed,
       ISNULL(max_paid, 0) as max_paid,
       case 
when crh_total <> 0 then ISNULL(ROUND((cast (crh_ontime as money) / cast (crh_total as money)), 4), 0) else 0 
end as history_ontime,
       case 
when total_trips <> 0 then ISNULL(ROUND(((cast (total_trips as money) - cast (total_late as money)) / cast (total_trips as money)), 4), 0) else 0 
end as on_time_percent,
       ISNULL(total_trips - total_late, 0) as on_time,
       case 
when total_trips <> 0 then ISNULL(ROUND((pay_linehaul / total_trips), 2), 0) else 0 
end as avg_total,
       case 
when total_trips <> 0 then ISNULL(ROUND((pay_fsc / total_trips), 2), 0) else 0 
end as avg_fuel,
       case 
when total_trips <> 0 then ISNULL(ROUND((pay_accessorial / total_trips), 2), 0) else 0 
end as avg_acc,
       case 
when last_billed <> 0 then ISNULL(ROUND(((last_billed - last_paid) / last_billed), 4), 0) else 0 
end as last_margin_percent,
       ISNULL(ROUND((last_billed - last_paid), 2), 0) as last_margin_amount,
       case 
when total_billed <> 0 then ISNULL(ROUND(((total_billed - (pay_linehaul + pay_accessorial + pay_fsc)) / total_billed), 4), 0) else 0 
end as lane_margin_percent,
       ISNULL(ROUND(total_billed - (pay_linehaul + pay_accessorial + pay_fsc), 2), 0) as lane_margin_amount,
       ISNULL((pay_linehaul + pay_accessorial + pay_fsc), 0) as total_paid,
       min_margin_percent,
       /*PTS 57012 CGK 3/31/2010*/
       --       CASE WHEN min_billed <> 0 THEN ISNULL(ROUND(((min_billed - min_paid)/min_billed), 4), 0)
       --            ELSE 0
       --       END min_margin_percent,
       min_margin_amount,
       /*PTS 57012 CGK 3/31/2010*/
       --		ISNULL(ROUND((min_billed - min_paid), 2), 0) min_margin_amount,	
       max_margin_percent,
       /*PTS 57012 CGK 3/31/2010*/
       --       CASE WHEN max_billed <> 0 THEN ISNULL(ROUND(((max_billed - max_paid)/max_billed), 4), 0)
       --            ELSE 0
       --       END max_margin_percent,
       max_margin_amount,
       /*PTS 57012 CGK 3/31/2010*/
       --       ISNULL(ROUND((max_billed - max_paid), 2), 0) max_margin_amount,
       --PTS 49332 JJF 20091008
       ISNULL(distance_to_origin, 0) as distance_to_origin,
       ISNULL(distance_to_destination, 0) as distance_to_destination,
       --END PTS 49332 JJF 20091008
       ISNULL(preferred_lane, '') as preferred_lane,
       --PTS 51918 JJF 20110210
       qualification_list_drv,
       qualification_list_trc,
       qualification_list_trl
--END PTS 51918 JJF 20110210
from   @temp1 t
where  t.trk_carrier in (select car_id
                              from   carrier with (nolock)
                              --PTS 53571 KMM/JJF 20100818 add car_id unknown to return empty result message
                              where  car_status <> 'OUT'
                                     or car_id = 'UNKNOWN');


GO
GRANT EXECUTE ON  [dbo].[d_cmpcarrier_adhoc_sp] TO [public]
GO

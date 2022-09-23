SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetInfoForPrerating_sp] (@billto varchar(8), @origincity int, @originzip varchar(10),
    @destcity int, @destzip varchar(10), @ordrevtype1 varchar(6), @ordrevtype2 varchar(6), @ordrevtype3 varchar(6),
    @ordrevtype4 varchar(6))
As
/* MODIFICSTION LOG
  4/11/10 created DPETE PTS51331 for rating with single nvo

*/

/* returns info not contained in OE or Dispatch for pre rating */
declare @localization char(1),@service_revtype varchar(10)
declare 
   @cmp_min_charge money ,
   @origin_servicezone varchar(6) ,
   @origin_servicearea varchar(6),
   @origin_servicecenter varchar(6),
   @origin_serviceregion varchar(6),
   @dest_servicezone varchar(6),
   @dest_servicearea varchar(6),
   @dest_servicecenter varchar(6),
   @dest_serviceregion varchar(6),
   @originstate  varchar(10),
   @DESTSTATE VARCHAR(10)




/*	PTS 26793 - DJM - Determine if Localization values should be calculated			*/
select @localization = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'ServiceLocalization'
Select @service_revtype = isNull(gi_string1,'UNKNOWN') from generalinfo where gi_name = 'ServiceRegionRevType'
select @service_revtype = isnull(@service_revtype,'UNKNOWN')
/* set fdefault values */
select @origin_servicezone = 'UNK',
   @origin_servicearea= 'UNK',
   @origin_servicecenter= 'UNK',
   @origin_serviceregion = 'UNK',
   @dest_servicezone = 'UNK',
   @dest_servicearea = 'UNK',
   @dest_servicecenter = 'UNK',
   @dest_serviceregion = 'UNK'

select @cmp_min_charge = isnull(cmp_min_charge,0.0) from company where cmp_id = @billto

select @originstate = cty_state from city where cty_code = @origincity
select @deststate = cty_state from city where cty_code = @destcity




if @service_revtype <> 'UNKNOWN' AND @localization = 'Y'
  BEGIN
     select @origin_servicezone =  cz_zone ,@origin_servicearea = cz_area
     from cityzip, city 
     where city.cty_code = @origincity
     and city.cty_nmstct = cityzip.cty_nmstct 
     and @originzip = cityzip.zip

     if @service_revtype = 'REVTYPE1'
      select @origin_servicecenter = max(svc_center),@origin_serviceregion = max(svc_region)
      from serviceregion sc,cityzip, city
      where city.cty_code = @origincity
      and cityzip.cty_nmstct = city.cty_nmstct
      and cityzip.zip = @originzip
      and cityzip.cz_area = sc.svc_area
      and sc.svc_revcode = @ordrevtype1

     if @service_revtype = 'REVTYPE2'
      select @origin_servicecenter = max(svc_center),@origin_serviceregion = max(svc_region)
      from serviceregion sc,cityzip, city
      where city.cty_code = @origincity
      and cityzip.cty_nmstct = city.cty_nmstct
      and cityzip.zip = @originzip
      and cityzip.cz_area = sc.svc_area
      and sc.svc_revcode = @ordrevtype2

     if @service_revtype = 'REVTYPE3'
      select @origin_servicecenter = max(svc_center),@origin_serviceregion = max(svc_region)
      from serviceregion sc,cityzip, city
      where city.cty_code = @origincity
      and cityzip.cty_nmstct = city.cty_nmstct
      and cityzip.zip = @originzip
      and cityzip.cz_area = sc.svc_area
      and sc.svc_revcode = @ordrevtype3

     if @service_revtype = 'REVTYPE4'
      select @origin_servicecenter = max(svc_center),@origin_serviceregion = max(svc_region)
      from serviceregion sc,cityzip, city
      where city.cty_code = @origincity
      and cityzip.cty_nmstct = city.cty_nmstct
      and cityzip.zip = @originzip
      and cityzip.cz_area = sc.svc_area
      and sc.svc_revcode = @ordrevtype4

     --PTS68142 MBR 03/19/13 Changed @origin_servicearea to @dest_servicearea and
     --@originzip to @destzip in the next statement
     select @dest_servicezone =  cz_zone ,@dest_servicearea = cz_area
     from cityzip, city 
     where city.cty_code = @destcity
     and city.cty_nmstct = cityzip.cty_nmstct 
     and @destzip = cityzip.zip

     if @service_revtype = 'REVTYPE1'
      select @dest_servicecenter = max(svc_center),@dest_serviceregion = max(svc_region)
      from serviceregion sc,cityzip, city
      where city.cty_code = @destcity
      and cityzip.cty_nmstct = city.cty_nmstct
      and cityzip.zip = @destzip
      and cityzip.cz_area = sc.svc_area
      and sc.svc_revcode = @ordrevtype1

     if @service_revtype = 'REVTYPE2'
      select @dest_servicecenter = max(svc_center),@dest_serviceregion = max(svc_region)
      from serviceregion sc,cityzip, city
      where city.cty_code = @destcity
      and cityzip.cty_nmstct = city.cty_nmstct
      and cityzip.zip = @destzip
      and cityzip.cz_area = sc.svc_area
      and sc.svc_revcode = @ordrevtype2

     if @service_revtype = 'REVTYPE3'
      select @dest_servicecenter = max(svc_center),@dest_serviceregion = max(svc_region)
      from serviceregion sc,cityzip, city
      where city.cty_code = @destcity
      and cityzip.cty_nmstct = city.cty_nmstct
      and cityzip.zip = @destzip
      and cityzip.cz_area = sc.svc_area
      and sc.svc_revcode = @ordrevtype3

     if @service_revtype = 'REVTYPE4'
      select @dest_servicecenter = max(svc_center),@dest_serviceregion = max(svc_region)
      from serviceregion sc,cityzip, city
      where city.cty_code = @destcity
      and cityzip.cty_nmstct = city.cty_nmstct
      and cityzip.zip = @destzip
      and cityzip.cz_area = sc.svc_area
      and sc.svc_revcode = @ordrevtype4
 END

select 
   @cmp_min_charge cmp_min_charge,
   @origin_servicezone origin_servicezone ,
   @origin_servicearea origin_servicearea,
   @origin_servicecenter origin_servicecenter,
   @origin_serviceregion origin_serviceregion,
   @dest_servicezone dest_servicezone,
   @dest_servicearea dest_servicearea,
   @dest_servicecenter dest_servicecenter,
   @dest_serviceregion  dest_serviceregion,
   @originstate originstate,
   @deststate deststate 

GO
GRANT EXECUTE ON  [dbo].[GetInfoForPrerating_sp] TO [public]
GO

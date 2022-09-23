SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[tripsheet_permits_sp] (@pl_movnumber int, @ps_permit_list varchar(100) = '') as

/**
 * 
 * NAME:
 * dbo.tripsheet_permits_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns a result set for a permit trip sheet
 *
 * RETURNS:
 * None.
 *
 * RESULT SETS: 
 * 
 * P_ID                          Permit Identity (identity of the permit)
 * P_Original_P_ID               Original Permit ID (used to track revisions)
 * PIA_Type                      Issuing Authority Type (City or State or userDefined from labelfile)
 * PM_Name                       Name of the Permit Master
 * st_abbr                       State of the permit (if State Issuing Authority)
 * cty_nmstct                    City of the permit (if City Issuing Authority)
 * P_Valid_From                  Date the Permit is Valid From
 * P_Valid_To                    Date the Permit is Valid until
 * P_Permit_Number               Permit ID Number
 * P_TransmitDate                Date the Permit was Transmited
 * P_OrderedDate                 Date the Permit was Ordered
 * p_createby                    User that inserted the permit to the database
 * trans_method                  Method of Permit Transmition
 * trans_to_type                 What Type entity the permit is being transfered to
 * trans_to                      ID it is being transmitted to
 * trans_fax_number              Fax Number of a transmit to if a truckstop is the trans_to_type
 * mov_number                    Movment Number
 * lgh_number                    Leg Number (if not a movement based permit)
 * ord_number                    Order Number the Permit pertains to
 * mpp_id                        Driver ID
 * mpp_fullname                  Driver Full Name (in the format of First M. Last)
 * trc_number                    Tractor ID
 * trl_id                        Trailer ID
 * trl_year                      Year of the Trailer Manufacture
 * trl_make                      Make of the Trailer
 * trl_licstate                  State Of the Trailer License
 * trl_licnum                    License of the Trailer
 * trl_serial                    Serial of the Trailer
 * print_date                    Date report was generated and printed on (SQL's time when the proc runs)
 * cmd_code                      Commodity code for the Order
 * cmd_name                      Commodity Name for the Order
 * orig_name                     Company name of the Origin
 * orig_phone                    Origin Company phone number
 * orig_address1                 Origin Address
 * origin_city_name              Origin City
 * origin_state                  Origin State
 * dest_name                     Company name of the Destination
 * dest_phone                    Destination Company Phone Number
 * dest_address1                 Destination Company Address
 * dest_city_name                Destination City
 * dest_state                    Destination State
 * trc_year                      Year of Tractor Manufacture
 * trc_make                      Make of the Tractor
 * trc_licstate                  State of the Tractor License
 * trc_licnum                    License Number of the Tractor
 * trc_serial                    VIN of the Tractor
 * trc_tareweight                Tare weight of the Tractor
 * trl_tareweight                Tare weight of the Trailer
 * default_height                Default Height of the Trip (commodity + default axle config)
 * default_length                Default Length of the Trip (commodity + default axle config)
 * default_weight                Default Weight of the Trip (commodity + default axle config)
 * default_width                 Default Width of the Trip (commodity + default axle config)
 * P_cmd_comment1                Comment 1 about the commodity that is permitted
 * P_cmd_comment2                Comment 2 about the commodity that is permitted
 * P_cmd_comment3                Comment 3 about the commodity that is permitted
 * fgt_length                    Max Length for the commodity
 * fgt_width                     Max Width for the commodity
 * fgt_height                    Max Height for the commodity
 * fgt_weight                    Max Weight for the commodity
 * ref_number                    SER Reference number for the pickup of the order commodity
 * stops_count                   Count of extra stops outside the pickup and delivery
 * p_uiseq                       User Interface sorting column
 * trans_ctystate                City and State of the Company or Truckstop location the permit is being transmitted to
 * PARAMETERS:
 * 001 - @pl_movnumber           movement number for the report
 * 002 - @ps_permit_list         coma seperated list of permit id's to print
 *
 * 
 *
 * Revision History
 * 8/10/05	-	Jason Bauwin	-	Inital Release
 * 4/12/05	-	Jason Bauwin	-	Altered to print blanket permits attached
                                 to the assets of the trip only if the
                                 jurisdiction is part of the trip
 * 8/18/06  - Jason Bauwin    -  Converted to SQL 2000 version to allow for table vars and usage of CSVStringsToTable_fn
 * 7/02/08 - SGB - Isolated transaction to prevent deadlock PTS 43490
*/
-- PTS 43490 SGB 07/02/08 add isolation
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



  DECLARE @permit_list TABLE (p_id int not null)

  DECLARE @output TABLE(
      output_P_ID int null, 
      P_Original_P_ID int null,
      PIA_Type varchar(6) null,
      PM_name varchar(50) null,
      st_abbr char(2) null,
      cty_nmstct varchar(30) null,
      P_Valid_From datetime null,
      P_Valid_To datetime null,
      P_Permit_Number varchar(50) null,
      P_TransmitDate datetime null,
      P_OrderedDate datetime null,
      p_createby	varchar(255) null,
      trans_method  varchar(20) null,
      trans_to_type varchar(20) null,
      trans_to varchar(111) null,
      trans_fax_number varchar(20) null,
      mov_number int null,
		lgh_number int null,
      ord_number varchar(12) null,
      mpp_id varchar(8) null,
      mpp_fullname varchar(100) null,
      trc_number varchar(8) null,
      trl_id varchar(13) null,
      trl_year int null,
      trl_make varchar (8) null,
      trl_licstate varchar(6) null,
      trl_licnum varchar (12) null,
      trl_serial varchar (20) null,
      print_date datetime null,
      cmd_code varchar(8) null,
      cmd_name varchar(60) null,
      orig_name varchar(100) null,
      orig_phone varchar(20) null,
      orig_address1 varchar(100) null,
      origin_city_name varchar (18) null,
      origin_state varchar(2) null,
      dest_name varchar(100) null,
      dest_phone varchar(20) null,
      dest_address1 varchar(100) null,
      dest_city_name varchar (18) null,
      dest_state varchar(2) null,
      trc_year int null,
      trc_make varchar(8) null,
      trc_licstate varchar(6) null,
      trc_licnum varchar(12) null,
      trc_serial varchar(20) null,
      trc_tareweight float null,
      trl_tareweight float null,
      default_height float null,
      default_length float null,
      default_weight float null,
      default_width  float null,
      permit_cmd_comment1 varchar(30) null,
      permit_cmd_comment2 varchar(30) null,
      permit_cmd_comment3 varchar(30) null,
      p_ordered_height float null, 
      p_ordered_width float null,
      fgt_length float null,
      fgt_width float null,
      fgt_height float null,
      fgt_weight float null,
      fgt_refnum varchar(30) null,
      stops_count int null,
      p_uiseq int null,
      trans_ctystate varchar(33))

  DECLARE @vl_orig_id int, 
          @vl_counter int, 
          @vl_p_id int,
          @vl_min_p_id int,
          @vl_rowcount int,
          @vl_counter2 int,
          @vl_lghnumber int,
          @v_height int,
          @v_length int,
          @v_weight int,
          @v_width int,
          @v_fgt_number int


  INSERT INTO @output 
  SELECT P.P_ID,
			P.P_Original_P_ID,
         UPPER(PIA.PIA_Type), 
         UPPER(PM.PM_Name),
			UPPER(PIA.st_abbr), 
			UPPER(PIA.cty_nmstct),
 			P.P_Valid_From, 
			P.P_Valid_To, 
			P.P_Permit_Number, 
			P.P_TransmitDate,
			P.P_OrderedDate,
         P.p_createby,
         P.P_Transmit_Method,
         P.P_Transmit_To_Type,
         P.P_Transmit_To,
         NULL AS trans_fax_number,
			p.mov_number,
			p.lgh_number,
         o.ord_number,
			mpp_id,
			UPPER(mpp_firstname + ' ' + isnull(mpp_middlename,'') + CASE isnull(mpp_middlename, '') when '' then '' else '. ' END  + mpp_lastname) as 'mpp_fullname',
			UPPER(trc.trc_number),
			trl.trl_id,
			trl.trl_year,
			UPPER(trl.trl_make),
         UPPER(trl.trl_licstate),
			UPPER(trl.trl_licnum),
			UPPER(trl.trl_serial),
			getdate(),
         cmd.cmd_code,
			UPPER(cmd.cmd_name),
			UPPER(ocmp.cmp_name),
			ocmp.cmp_primaryphone,
			UPPER(ocmp.cmp_address1),
			UPPER(octy.cty_name),
			UPPER(octy.cty_state),
			UPPER(dcmp.cmp_name),
			dcmp.cmp_primaryphone,
			UPPER(dcmp.cmp_address1),
			UPPER(dcty.cty_name),
			UPPER(dcty.cty_state),
			trc.trc_year,
			UPPER(trc.trc_make),
         UPPER(trc_licstate),
			UPPER(trc.trc_licnum),
			UPPER(trc.trc_serial),
			trc.trc_tareweight,
			trl.trl_tareweight,
         0.00,
         0.00,
         0.00,
         0.00,
         P.P_cmd_comment1,
         P.P_cmd_comment2,
         P.P_cmd_comment3,
         isnull(P.P_ordered_height,0.00),
         isnull(P.P_ordered_width,0.00),
         0.00,
         0.00,
         0.00,
         0.00,
         NULL,
         0,
         P.p_uiseq,
         ''
   FROM Permits P 
   JOIN Permit_Master PM on P.PM_ID = PM.PM_ID 
   JOIN Permit_Issuing_Authority PIA on PM.PIA_ID = PIA.PIA_ID
   JOIN orderheader o on o.ord_hdrnumber = p.ord_hdrnumber
   JOIN legheader l on l.lgh_number = p.lgh_number
   JOIN manpowerprofile mpp on l.lgh_driver1 = mpp.mpp_id
   JOIN tractorprofile trc on l.lgh_tractor  = trc.trc_number
   JOIN trailerprofile trl on l.lgh_primary_trailer = trl.trl_id
   JOIN commodity cmd on cmd.cmd_code = o.cmd_code
   JOIN company ocmp on ocmp.cmp_id = o.ord_shipper
   JOIN city octy on octy.cty_code = ocmp.cmp_city
   JOIN company dcmp on dcmp.cmp_id = o.ord_consignee
   JOIN city dcty on dcty.cty_code = dcmp.cmp_city
/*Permit must meet one of the following criteria:  (explination of where clause)
  1) the movement (movement based permit), or   
  2) any leg on the movement (leg based permit), or 
  3) to one of the assets with no move or leg (blanket permit) 
  4) have a valid from and valid to that are outside the scope of the trip
*/
   WHERE (P.mov_number = @pl_movnumber OR 
          P.lgh_number in (select lgh_number 
                             from legheader 
                            where mov_number = @pl_movnumber) OR 
         (isnull(P.mov_number,0) = 0 AND 
          isnull(P.lgh_number,0) = 0 AND 
          (p.asgn_type = 'trc' and p.asgn_id in(select lgh_tractor 
                                                  from legheader 
                                                 where mov_number = @pl_movnumber)
           OR  p.asgn_type = 'drv' and p.asgn_id in(select lgh_driver1
                                                  from legheader 
                                                 where mov_number = @pl_movnumber)
           OR  p.asgn_type = 'trl' and p.asgn_id in(select lgh_primary_trailer
                                                  from legheader 
                                                 where mov_number = @pl_movnumber)))
         AND P.P_Valid_From < o.ord_startdate
			AND P.P_Valid_To > o.ord_completiondate)


--now remove all the blanket permits whose jurisdiction does not apply to this state
delete from @output
 where st_abbr not in (select sm_state 
                         from statemiles
                         join mileagetable on statemiles.mt_identity = mileagetable.mt_identity
                         join stops on stops.stp_lgh_mileage_mtid = mileagetable.mt_identity
                         where stops.mov_number = @pl_movnumber)
   AND isnull(mov_number,0) = 0 
   AND isnull(lgh_number,0) = 0




--now all permits are in the temp table need to remove all those that have been revised
  select @vl_counter = min(output_P_ID)
    from @output

  While @vl_counter is not null
    begin
      select @vl_p_id = output_P_ID,
             @vl_orig_id = p_original_p_id
        from @output
       where output_P_ID = @vl_counter
      --if there is another permit with a higher p_id but the same original the current permit has revisions and should be removed
      if exists( select 1
                   from @output
                  where p_original_p_id = @vl_orig_id
                    and output_P_ID > @vl_p_id)
        begin
          delete from @output
                where output_P_ID = @vl_counter
        end
      --go to the next one
      select @vl_counter = min(output_P_ID)
        from @output
       where output_P_ID > @vl_counter
    end

--JLB PTS 33382 remove all permits that are not in the passed in list if any were passed in
if len(@ps_permit_list) > 0
begin
  delete from @output
   where output_p_id not in (select value 
                               from CSVStringsToTable_fn(@ps_permit_list))
end

   


--update the freight detail DIMS
update @output
   set fgt_length = (select max(fgt_length)
                      from freightdetail, stops
                     where freightdetail.stp_number = stops.stp_number
                       and stops.mov_number = @pl_movnumber
                       and stops.ord_hdrnumber > 0)

update @output
   set fgt_width = (select max(fgt_width)
                      from freightdetail, stops
                     where freightdetail.stp_number = stops.stp_number
                       and stops.mov_number = @pl_movnumber
                       and stops.ord_hdrnumber > 0)

update @output
   set fgt_height = (select max(fgt_height)
                      from freightdetail, stops
                     where freightdetail.stp_number = stops.stp_number
                       and stops.mov_number = @pl_movnumber
                       and stops.ord_hdrnumber > 0)

update @output
   set fgt_weight = (select max(fgt_weight)
                      from freightdetail, stops
                     where freightdetail.stp_number = stops.stp_number
                       and stops.mov_number = @pl_movnumber
                       and stops.ord_hdrnumber > 0)

--get the referencenumber for the ordered commodity
select @v_fgt_number = min(fgt_number)
  from freightdetail
  join stops on stops.stp_number = freightdetail.stp_number
 where stops.stp_number in (select stp_number
                              from stops
                             where ord_hdrnumber > 0
                               and mov_number = @pl_movnumber)
   and freightdetail.cmd_code = (select max(cmd_code)
                                   from @output
                                  where cmd_code <> 'UNKNOWN')

update @output
   set fgt_refnum = ref_number
  from referencenumber
 where ref_type = 'SER'
   and ref_table = 'freightdetail'
   and ref_tablekey = @v_fgt_number
   and ref_sequence = (select min(ref_sequence)
                         from referencenumber
                        where ref_type = 'SER'
                          and ref_table = 'freightdetail'
                          and ref_tablekey = @v_fgt_number)

 
select @vl_counter2 = min(output_P_ID) 
  from @output

while @vl_counter2 is not null
begin


--update transmit method label name
   update @output
      set trans_method = UPPER(name)
     from permits p, labelfile l, @output o
    where p.p_transmit_method = l.abbr
      and output_P_ID = @vl_counter2
      and output_P_ID = p.p_id
      and labeldefinition = 'PermitTransmitMethod'

--update fax numbers and city info for any truckstops
   update @output
      set trans_fax_number = truckstops.ts_fax_number,
          trans_ctystate = truckstops.ts_city + ',' + truckstops.ts_state
     from truckstops
    where trans_to_type = 'TRCSTP'
      and truckstops.ts_code = trans_to
      and output_P_ID = @vl_counter2

--update fax numbers and city info for any companies
   update @output
      set trans_fax_number = company.cmp_faxphone,
          trans_ctystate = city.cty_name + ',' + city.cty_state
     from company
     join city on company.cmp_city = city.cty_code
    where trans_to_type = 'CMP'
      and company.cmp_id = trans_to
      and output_P_ID = @vl_counter2


--update transmit to full name
   update @output
      set trans_to = trans_to  + ' - '+ (CASE trans_to_type
                                           WHEN 'TRCSTP' THEN (select UPPER(ts_name)
                                                                 from truckstops
                                                                 join @output on  truckstops.ts_code = trans_to
                                                                where output_P_ID = @vl_counter2)
                                           WHEN 'DRV' THEN mpp_fullname
                                           WHEN 'TRC' THEN trc_number
                                           WHEN 'CMP' THEN (select cmp_name
                                        from company
                                                              join @output on company.cmp_id = trans_to
                                                             where output_P_ID = @vl_counter2)
                                          END)
    where output_P_ID = @vl_counter2

--update transmit to type
   update @output
      set trans_to_type = (CASE trans_to_type
                           WHEN 'TRCSTP' THEN 'TRUCKSTOP'
                           WHEN 'DRV' THEN 'DRIVER'
                           WHEN 'TRC' THEN 'TRACTOR'
                           WHEN 'CMP' THEN 'COMPANY'
                           END)
    where output_P_ID = @vl_counter2


--update transmit Type label name
   update @output
      set trans_method = UPPER(name)
     from permits p, labelfile l, @output
    where p.p_transmit_method = l.abbr
      and output_P_ID = @vl_counter2
      and output_P_ID = p.p_id
      and labeldefinition = 'PermitTransmitType'

--clear any UNKNOWN transmit types
   update @output
      set trans_method = NULL
    where trans_method = 'UNKNOWN'

   --get the dims for each leg
   select @vl_lghnumber = lgh_number,
          @vl_p_id = output_P_ID
     from @output
    where output_P_ID = @vl_counter2
/*
   select @v_height = max(fgt_height)
     from @output
   if @v_height < (select sum((isnull(pac_previousdistance,0) + isnull(pac_pad,0) + isnull(pac_overhang,0)))
                     from permit_axle_configuration
                    where p_id = @vl_p_id)
      select @v_height = sum((isnull(pac_previousdistance,0) + isnull(pac_pad,0) + isnull(pac_overhang,0)))
        from permit_axle_configuration
       where p_id = @vl_p_id
*/
   select @v_length = (select sum(isnull(pac_previousdistance, 0)) - abs(sum(isnull(pac_pad, 0)))
                      from permit_axle_configuration
                     where isnull(p_id, 0) = 0
                       and asgn_type = 'TRC'
                       and asgn_id = (select trc_number
                                        from @output
                                       where trc_number <> 'UNKNOWN'
                                         and p_id = @vl_counter2))
    select @v_length = (@v_length + (select sum(isnull(pac_previousdistance, 0)) + abs(sum(isnull(pac_pad, 0)))
                                  from permit_axle_configuration
                                 where isnull(p_id, 0) = 0
                                   and asgn_type = 'TRL'
                                   and asgn_id = (select trl_id
                                                    from @output
                                                   where trl_id <> 'UNKNOWN'
                                                     and p_id = @vl_counter2)))

   select @v_width = max(pac_width)
     from permit_axle_configuration
    where isnull(p_id, 0) = 0
      and (asgn_type = 'TRC' and asgn_id = (select trc_number from @output where trc_number <> 'UNKNOWN' and p_id = @vl_counter2)
          OR (asgn_type = 'TRL' and asgn_id = (select trl_id from @output where trl_id <> 'UNKNOWN' and p_id = @vl_counter2)))
      
   --update the max dims for the movement
   update @output 
      set default_height = @v_height,
          default_length = @v_length,
          default_weight = @v_weight,
          default_width  = @v_width
    where output_P_ID = @vl_counter2
   
   
   --get the next permit to update
      select @vl_counter2 = min(output_P_ID) 
        from @output
       where output_P_ID > @vl_counter2
   end

--count the loaded stops
update @output
   set stops_count = (select count(*)
                        from stops
                       where mov_number = @pl_movnumber
                         and ord_hdrnumber > 0) - 2,
       mov_number = @pl_movnumber

  --return results
  select output_P_ID,
      P_Original_P_ID,
      PIA_Type,
      PM_Name,
      st_abbr,
      cty_nmstct,
      P_Valid_From,
      P_Valid_To,
      P_Permit_Number,
      P_TransmitDate,
      P_OrderedDate,
      p_createby,
      trans_method,
      trans_to_type,
      trans_to,
      trans_fax_number,
      mov_number,
		lgh_number,
      ord_number,
      mpp_id,
      mpp_fullname,
      trc_number,
      trl_id,
      trl_year,
      trl_make,
      trl_licstate,
      trl_licnum,
      trl_serial,
      print_date,
      cmd_code,
      cmd_name,
      orig_name,
      orig_phone,
      orig_address1,
      origin_city_name,
      origin_state,
      dest_name,
      dest_phone,
      dest_address1,
      dest_city_name,
      dest_state,
      trc_year,
      trc_make,
      trc_licstate,
      trc_licnum,
      trc_serial,
      trc_tareweight,
      trl_tareweight,
      default_height,
      default_length,
      default_weight,
      default_width,
      permit_cmd_comment1,
      permit_cmd_comment2,
      permit_cmd_comment3,
      p_ordered_height, 
      p_ordered_width,
      fgt_length,
      fgt_width,
      fgt_height,
      fgt_weight,
      fgt_refnum,
      stops_count,
      p_uiseq,
      trans_ctystate
    from @output 
    order by p_uiseq,p_original_p_id, output_P_ID desc

-- PTS 43490 SGB 07/02/08 add end isolation
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
GRANT EXECUTE ON  [dbo].[tripsheet_permits_sp] TO [public]
GO

CREATE TABLE [dbo].[stops]
(
[ord_hdrnumber] [int] NOT NULL,
[stp_number] [int] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_city] [int] NOT NULL,
[stp_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_schdtearliest] [datetime] NULL,
[stp_origschdt] [datetime] NULL,
[stp_arrivaldate] [datetime] NULL,
[stp_departuredate] [datetime] NULL,
[stp_reasonlate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_schdtlatest] [datetime] NULL,
[lgh_number] [int] NULL,
[mfh_number] [int] NULL,
[stp_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_paylegpt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__stops__stp_payle__3DA903EC] DEFAULT ('Y'),
[shp_hdrnumber] [int] NULL,
[stp_sequence] [int] NULL,
[stp_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_lgh_sequence] [int] NULL,
[trl_id] [char] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_mfh_sequence] [int] NULL,
[stp_event] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_mfh_position] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_lgh_position] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_mfh_status] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_lgh_status] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_ord_mileage] [int] NULL,
[stp_lgh_mileage] [int] NULL,
[stp_mfh_mileage] [int] NULL,
[mov_number] [int] NULL,
[timestamp] [timestamp] NULL,
[stp_loadstatus] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_weight] [float] NULL,
[stp_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_count] [decimal] (10, 2) NULL,
[stp_countunit] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_comment] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reasonlate_depart] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_screenmode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[skip_trigger] [tinyint] NULL,
[stp_volume] [float] NULL,
[stp_volumeunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_dispatched_sequence] [int] NULL,
[stp_arr_confirmed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_dep_confirmed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_stp_type1] DEFAULT (''),
[stp_redeliver] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__stops__stp_redel__7484378A] DEFAULT ('0'),
[stp_osd] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_pudelpref] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_phonenumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_delayhours] [float] NULL,
[stp_ooa_mileage] [float] NULL,
[stp_zipcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_OOA_stop] [int] NULL CONSTRAINT [DF__stops__stp_OOA_s__75785BC3] DEFAULT (0),
[stp_address] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_transfer_stp] [int] NULL,
[stp_phonenumber2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_address2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_podname] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_custpickupdate] [datetime] NULL,
[stp_custdeliverydate] [datetime] NULL,
[stp_cmp_close] [int] NULL,
[stp_activitystart_dt] [datetime] NULL,
[stp_activityend_dt] [datetime] NULL,
[stp_departure_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_eta] [datetime] NULL,
[stp_etd] [datetime] NULL,
[stp_transfer_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_trip_mileage] [int] NULL,
[stp_stl_mileage_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmp_evt_number] [int] NULL,
[tmp_fgt_number] [int] NULL,
[stp_pallets_in] [int] NULL,
[stp_pallets_out] [int] NULL,
[stp_pallets_received] [int] NULL,
[stp_pallets_shipped] [int] NULL,
[stp_pallets_rejected] [int] NULL,
[psh_number] [int] NULL,
[stp_dispatched_status] [int] NULL,
[stp_advreturnempty] [int] NULL,
[stp_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_loadingmeters] [decimal] (12, 4) NULL,
[stp_loadingmetersunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_cod_amount] [decimal] (8, 2) NULL,
[stp_cod_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_extra_count] [real] NULL,
[stp_extra_weight] [float] NULL,
[stp_alloweddet] [int] NULL,
[stp_detstatus] [int] NOT NULL CONSTRAINT [DF__stops__stp_detst__06BA5863] DEFAULT (0),
[stp_gfc_arr_radius] [decimal] (7, 2) NULL,
[stp_gfc_arr_radiusunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_gfc_arr_timeout] [int] NULL,
[stp_tmstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reasonlate_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reasonlate_depart_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_est_drv_time] [int] NULL,
[stp_est_activity] [int] NULL,
[nlm_time_diff] [int] NULL,
[stp_lgh_mileage_mtid] [int] NULL,
[stp_count2] [decimal] (10, 2) NULL,
[stp_countunit2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_ord_toll_cost] [money] NULL,
[stp_ord_mileage_mtid] [int] NULL,
[stp_ooa_mileage_mtid] [int] NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_stops_last_updateby] DEFAULT (case when charindex('\',suser_sname())>(0) then left(substring(suser_sname(),charindex('\',suser_sname())+(1),len(suser_sname())),(20)) else left(suser_sname(),(20)) end),
[last_updatedate] [datetime] NULL CONSTRAINT [DF_stops_last_updatedate] DEFAULT (getdate()),
[last_updatebydepart] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedatedepart] [datetime] NULL,
[stp_unload_paytype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_transferred] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_GeoCodeRequested] [datetime] NULL,
[stp_reasonlate_min] [int] NULL,
[stp_reasonlate_depart_min] [int] NULL,
[stp_gfc_arv_radiusMiles] [decimal] (7, 2) NULL,
[stp_gfc_dep_radiusMiles] [decimal] (7, 2) NULL,
[stp_gfc_lat] [decimal] (12, 4) NULL,
[stp_gfc_long] [decimal] (12, 4) NULL,
[stp_aad_arvTime] [datetime] NULL,
[stp_aad_arvConfidence] [int] NULL,
[stp_aad_depTime] [datetime] NULL,
[stp_aad_depConfidence] [int] NULL,
[stp_aad_lastckc_lat] [decimal] (12, 4) NULL,
[stp_aad_lastckc_long] [decimal] (12, 4) NULL,
[stp_aad_lastckc_time] [datetime] NULL,
[stp_aad_lastckc_tripStatus] [int] NULL,
[stp_aad_laststartckc_lat] [decimal] (12, 4) NULL,
[stp_aad_laststartckc_long] [decimal] (12, 4) NULL,
[stp_aad_laststartckc_time] [datetime] NULL,
[stp_aad_laststartckc_tripStatus] [int] NULL,
[stp_aad_arvckc_lat] [decimal] (12, 4) NULL,
[stp_aad_arvckc_long] [decimal] (12, 4) NULL,
[stp_aad_arvckc_time] [datetime] NULL,
[stp_aad_arvckc_tripStatus] [int] NULL,
[stp_aad_depckc_lat] [decimal] (12, 4) NULL,
[stp_aad_depckc_long] [decimal] (12, 4) NULL,
[stp_aad_depckc_time] [datetime] NULL,
[stp_aad_depckc_tripStatus] [int] NULL,
[stp_lgh_mileage_stlrate] [int] NULL,
[stp_ord_mileage_stlrate] [int] NULL,
[stp_rescheduledate] [datetime] NULL,
[stp_showas_cmpid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_origarrival] [datetime] NULL,
[stp_timewindow] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_firm_appt_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_delay_eligible] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_mileagetype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_stp_mileagetype] DEFAULT (''),
[stp_ico_stp_number_parent] [int] NULL,
[stp_ico_stp_number_child] [int] NULL,
[RailServiceLevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_AppointmentStatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_rpt_miles] [decimal] (7, 2) NULL,
[stp_rpt_miles_mtid] [int] NULL,
[stp_span_days] [int] NULL,
[stp_CustomerRequestDate] [datetime] NULL,
[stp_empty_split] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_id2] [char] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_id3] [char] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_optimizationdate] [datetime] NULL,
[stp_app_eqcodes] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[dt_stops_consolidated] ON [dbo].[stops] FOR DELETE AS 
/* 
 * REVISION HISTORY:
 * 09/26/2006 PTS34310 - JG - consolidate and optimize trigger 
 *            "Delete" logic in iut_stops_createpurchaseservice, iutd_stops_tmail_updates,
 *            and dt_stops were consolidated into this trigger.
*/
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

--PTS34310 prevent empty firing
if not exists (select 1 from deleted) return
--PTS34310 end

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

----------------------------------------------------------------------------------
--PTS34310 jg begin logic in old dt_stops trigger
----------------------------------------------------------------------------------
DELETE event
FROM deleted, stops
WHERE stops.lgh_number = deleted.lgh_number AND
	stops.stp_number = event.stp_number AND
	event.evt_sequence > 1 AND
	event.stp_number <> deleted.stp_number AND
	--PTS79314 JJF 20140806 add IHMT 
	deleted.stp_event IN ( 'BMT', 'HMT', 'IHMT' ) AND
	--PTS79314 JJF 20140806 add IDMT 
	(event.evt_eventcode = 'DMT' OR event.evt_eventcode = 'IDMT') AND
	event.evt_trailer1 = ( SELECT MIN ( evt_trailer1 )
				FROM event
				WHERE deleted.stp_number = event.stp_number)

DELETE event 
FROM event, deleted 
WHERE event.stp_number = deleted.stp_number


DELETE freightdetail
FROM freightdetail, deleted
WHERE freightdetail.stp_number = deleted.stp_number

/* PTS #3040 - MLS 9/22/97 */
/*
DELETE loadrequirement
FROM loadrequirement, deleted
WHERE loadrequirement.stp_number = deleted.stp_number
*/

/* PTS #3040 */
   
/* PTS #14037 - PJC 02/21/03   */
UPDATE inventory_log
SET inventory_log.il_invtype = 'CYC', stp_number = NULL, lgh_number = NULL
WHERE inventory_log.stp_number = stp_number
/* PTS #14037                  */

DELETE referencenumber
FROM referencenumber, deleted
WHERE referencenumber.ref_tablekey = deleted.stp_number AND
	referencenumber.ref_table ='stops'


/********************************************************************************
*                                               LOG DELETED STOPS IF LogRouteMods OPTION IS YES
*********************************************************************************/
if ((select count(*)    
	FROM generalinfo,orderheader,deleted  
   WHERE  generalinfo.gi_name = 'LogRouteMods' AND  
	  generalinfo.gi_string1 = 'YES'   and
			 orderheader.ord_hdrnumber =  deleted.ord_hdrnumber) > 0) 
	 
	INSERT INTO trip_modification_log  
	 ( ord_hdrnumber,   
	   stp_number,   
	   tml_date,   
	   tml_event,   
	   stp_event,   
	   cmp_id,   
	   user_id,   
	   tml_revtype1,   
	   tml_revtype2,   
	   tml_revtype3,   
	   tml_revtype4,   
	   stp_sequence,   
	   stp_reftype,   
	   stp_refnum,   
	   ord_number,   
	   ord_subcompany,   
	   tml_orderby,
			  stp_schdtearliest,
			  stp_schdtlatest,
			  stp_arrivaldate,
			  stp_departuredate )  

		select deleted.ord_hdrnumber,   
		deleted.stp_number,   
		getdate(),   
		'DELETE',   
		deleted.stp_event,   
		deleted.cmp_id,   
		suser_sname(),
		orderheader.ord_revtype1,   
		orderheader.ord_revtype2,   
		orderheader.ord_revtype3,   
		orderheader.ord_revtype4,   		deleted.stp_sequence,   
		deleted.stp_reftype,   
		deleted.stp_refnum,   
		orderheader.ord_number,   
		orderheader.ord_subcompany,   
		orderheader.ord_company,
-- PTS 23972 -- BL (start)
--				convert(datetime, "00/00/00"),
--				convert(datetime,"00/00/00"),
--				convert(datetime,"00/00/00"),
--				convert(datetime,"00/00/00")
				convert(datetime, '1950-01-01'),
				convert(datetime,'1950-01-01'),
				convert(datetime,'1950-01-01'),
				convert(datetime,'1950-01-01')
-- PTS 23972 -- BL (end)
			from deleted, orderheader, labelfile
			where orderheader.ord_hdrnumber = deleted.ord_hdrnumber and
					orderheader.ord_status = labelfile.abbr and
					labelfile.labeldefinition = 'DispStatus' and
					labelfile.code between 200 and 400

--PTS34310 jg end logic in old dt_stops trigger
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--PTS34310 jg begin logic(DELETE) relocated from iut_stops_createpurchaseservice
----------------------------------------------------------------------------------
DECLARE @eventcode varchar(6),
        @purchaseservice char(1),
        @stpnumber int,
        @cmdcode varchar(8),
        @lghnumber int,
        @cmpid varchar(8),
        @ordhdr int,
        @dropdt datetime,
        @pickupdt datetime,
        --PTS 55626 JJF 20110816
        --@pshid varchar(15),
        @pshid varchar(17),
        --END PTS 55626 JJF 20110816
        @ordnumber varchar(12),
        @nextletter varchar(26),
        @cmdpscount int,
        @cmppscount int,
        @pocount int,
        @pochar char(1),
        @pshnumber int,
        @movnumber int,
	@pshvendorid varchar(8),
	@fgt_refnum varchar(30),
        @count int,
        @trl_id varchar(13),
	@max_psh_number int,
	@ascii	int

SELECT @nextletter = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

SELECT @eventcode = stp_event,
                  @stpnumber = stp_number,
                  @cmdcode = cmd_code,
                  @lghnumber = lgh_number,
                  @cmpid = cmp_id,
                  @ordhdr = ord_hdrnumber,
                  @dropdt = stp_arrivaldate,
                  @pickupdt = DATEADD(hour, 6, stp_departuredate),
                  @movnumber = mov_number,
                  @pshnumber = psh_number,
                  @trl_id = trl_id
     FROM inserted

IF @eventcode is null /* Must be a delete */
BEGIN
     SELECT @eventcode = stp_event,
                       @stpnumber = stp_number,
                       @cmdcode = cmd_code,
                       @lghnumber = lgh_number,
                       @cmpid = cmp_id,
                       @ordhdr = ord_hdrnumber,
                       @dropdt = stp_arrivaldate,
                       @pickupdt = DATEADD(hour, 6, stp_departuredate),
                       @movnumber = mov_number,
                       @pshnumber = psh_number,
                       @trl_id = trl_id
         FROM deleted
     IF @pshnumber > 0
     BEGIN
          DELETE FROM purchaseservicedetail 
               WHERE psh_number = @pshnumber
          DELETE FROM purchaseserviceheader
               WHERE psh_number = @pshnumber
     END
END
ELSE
BEGIN
     IF Update(stp_event)
     BEGIN
          SELECT @purchaseservice = ect_purchase_service
              FROM eventcodetable
           WHERE abbr = @eventcode
          IF @purchaseservice IS NOT NULL AND @purchaseservice = 'Y'
          BEGIN
               IF @ordhdr = 0 
               BEGIN
                   /* PTS17481 MBR 03/05/03 */
                   SELECT @ordhdr = ord_hdrnumber
                     FROM stops
                    WHERE mov_number = @movnumber AND
                          stp_type = 'PUP'
               END
               SELECT @pshvendorid = thirdpartyprofile.tpr_id
                 FROM thirdpartyprofile, company
                WHERE tpr_id = @cmpid  AND
                      tpr_id = cmp_id AND
                      cmp_service_location = 'Y' AND
					  ISNULL(cmp_service_location_own, 'N') = 'N'
               IF @pshvendorid is not null 
               BEGIN
                    SELECT @cmppscount = count(*)
                      FROM vendorpurchaseservices
                     WHERE cmp_id = @cmpid
                    DECLARE cmd_cursor CURSOR FOR
                         SELECT DISTINCT cmd_code, fgt_refnum
                           FROM freightdetail
                          WHERE freightdetail.stp_number IN (SELECT stp_number
                                                               FROM stops
                                                              WHERE mov_number = @movnumber AND
                                                                    stp_type = 'PUP')
                    OPEN cmd_cursor
                    FETCH NEXT FROM cmd_cursor INTO @cmdcode, @fgt_refnum
                    SET @count = 1
                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                         SELECT @cmdpscount = count(*)
                             FROM commoditypurchaseservices
                          WHERE cmd_code = @cmdcode
                         IF @cmppscount > 0 or @cmdpscount > 0 
                         BEGIN
                              IF @count = 1
                              BEGIN
                                   /* PTS17481 MBR 03/05/03 */
                                   SELECT @ordnumber = ord_hdrnumber
                                     FROM stops
                                    WHERE mov_number = @movnumber AND
                                          stp_type = 'PUP'
                                   --PTS16704 MBR 12/31/02
								   SELECT @max_psh_number = IsNull(Max(psh_number), 0)
									 FROM purchaseserviceheader
									WHERE ord_hdrnumber = @ordhdr
				    
									--PTS 55626 JJF 20110816
									IF EXISTS	(	SELECT	*
													FROM	generalinfo
													WHERE	gi_name = 'PurchaseServiceNumbering'
															and gi_string1 = '1'
												) BEGIN

										SELECT	@pshid =	CASE CHARINDEX('-', psh_id, 1)
																WHEN 0 THEN RIGHT(psh_id, 1)
																ELSE SUBSTRING(psh_id, CHARINDEX('-', psh_id, 1) + 1, LEN(psh_id))
															END
										FROM 	purchaseserviceheader
										WHERE	psh_number = @max_psh_number

										SELECT @pshid = ISNULL(@pshid, '')
										
										IF len(@pshid) = 0 BEGIN
											SELECT	@pshid = RTRIM(@ordnumber) + '-0001'
										END
										ELSE IF len(@pshid) = 1 BEGIN
											SELECT	@ascii = ASCII(RIGHT(@pshid,1))
											SELECT	@ascii = @ascii + 1
											SELECT	@pochar = CHAR(@ascii)
											SELECT	@pshid = RTRIM(@ordnumber) + @pochar
										END
										ELSE BEGIN
											--Since we are in a trigger, would rather not block update due to max service records...
											IF CONVERT(int, @pshid) >= 9999 BEGIN
												SELECT @pshid = RTRIM(@ordnumber) + '-9999'
											END
											ELSE BEGIN
												SELECT	@pshid = RTRIM(@ordnumber) + '-' + RIGHT('0000' + CONVERT(varchar(4), CONVERT(int, @pshid) + 1), 4)
											END
										END
									END
									
									ELSE BEGIN
										IF @max_psh_number > 0 BEGIN
											SELECT	@pshid = psh_id
											FROM	purchaseserviceheader
											WHERE	psh_number = @max_psh_number

											SELECT	@ascii = ASCII(RIGHT(@pshid,1))
											SELECT	@ascii = @ascii + 1
											SELECT	@pochar = CHAR(@ascii)
											SELECT	@pshid = RTRIM(@ordnumber) + @pochar
										END
										ELSE BEGIN
											SELECT @pochar = 'A'
											SELECT @pshid = RTRIM(@ordnumber) + @pochar
										END
									END

								   --IF @max_psh_number > 0
								   --BEGIN
								   --   SELECT @pshid = psh_id
								   --     FROM purchaseserviceheader
								   --    WHERE psh_number = @max_psh_number
								   --   SELECT @ascii = ASCII(RIGHT(@pshid,1))
								   --   SELECT @ascii = @ascii + 1
								   --   SELECT @pochar = CHAR(@ascii)
								   --   SELECT @pshid = RTRIM(@ordnumber) + @pochar
								   --END
								   --ELSE
								   --BEGIN
								   --   SELECT @pochar = 'A'
								   --   SELECT @pshid = RTRIM(@ordnumber) + @pochar
								   --END
								   --END PTS 55626 JJF 20110816
				   
                                   EXECUTE @pshnumber = getsystemnumber 'PURCHSRV',''
                                   INSERT INTO purchaseserviceheader (psh_id, psh_number, psh_status, psh_vendor_id, 
                                                                      psh_drop_dt, psh_pickup_dt, psh_promised_dt, 
                                                                      ord_hdrnumber, psh_service, stp_number, trl_id)
                                                              values (@pshid, @pshnumber, 'HLD', @pshvendorid, @dropdt,
                                                                      @pickupdt,@pickupdt, @ordhdr, @eventcode, 
                                                                      @stpnumber, @trl_id)
                                   SET @count = 2
                              END
                              INSERT INTO purchaseservicedetail (psh_number, psd_type, psd_qty, psd_estrate, psd_heelqty,
                                                                 psd_rate, cmd_code, fgt_refnum)
                              SELECT @pshnumber, psd_type, 1, cps_estrate, 1, 0, @cmdcode, @fgt_refnum
                               FROM commoditypurchaseservices
                              WHERE cmd_code = @cmdcode
                         END
                         FETCH NEXT FROM cmd_cursor INTO @cmdcode, @fgt_refnum
                     END
                    CLOSE cmd_cursor
                    DEALLOCATE cmd_cursor
                    UPDATE purchaseservicedetail
                       SET purchaseservicedetail.psd_estrate = vendorpurchaseservices.vps_estrate
                      FROM purchaseservicedetail, vendorpurchaseservices
                     WHERE purchaseservicedetail.psh_number = @pshnumber AND
                           purchaseservicedetail.psd_type = vendorpurchaseservices.psd_type AND
                           vendorpurchaseservices.cmp_id = @pshvendorid
                    UPDATE stops SET psh_number = @pshnumber
                         WHERE stp_number = @stpnumber
               END
          END
     END
     IF UPDATE(cmp_id) and @pshnumber > 0 
     BEGIN
          UPDATE purchaseserviceheader
                   SET psh_vendor_id = @cmpid,
                             psh_drop_dt = @dropdt,
                             psh_pickup_dt = @pickupdt,
                             psh_promised_dt = @pickupdt
           WHERE psh_number = @pshnumber
     END
END

--PTS34310 jg end logic(DELETE) relocated from iut_stops_createpurchaseservice
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--PTS34310 jg begin logic(DELETE) relocated from iutd_stops_tmail_updates
----------------------------------------------------------------------------------

-- trigger for PTS12969 send info to TMail when order changes

declare @TMailDateChgForm int, 
	@TMailStopChangeFormID int,
	@ord int, @mov int, @lgh int, @stp int, @temp varchar(60),
	@delete char(1), @stp_type varchar(6), @trc varchar(8),
	@outstatus varchar(6), @lgh_dsp_date datetime

--PTS34310 begin multi-row delete handling logic
--only run for singe row updates
--if (select count(*) from inserted) > 1 or
--	(select count(*) from deleted) > 1 Return
if NOT ( (select count(*) from inserted) > 1 or
	(select count(*) from deleted) > 1 )
BEGIN
--PTS34310 end multi-row delete handling logic

select @TMailDateChgForm = 0, @TMailStopChangeFormID = 0 

select @temp = gi_string1 from generalinfo
where gi_name = 'TMailDateChangeFormID'
if isnumeric(@temp) = 1 select @TMailDateChgForm = convert(int, @temp)

select @temp = gi_string1 from generalinfo
where gi_name = 'TMailStopChangeFormID'
if isnumeric(@temp) = 1 select @TMailStopChangeFormID = convert(int, @temp)

--make sure one of the option are turned on
if @TMailDateChgForm + @TMailStopChangeFormID > 0
begin
	select @delete = 'N'

	select @stp = stp_number,
		@ord = ord_hdrnumber,
		@mov = mov_number,
		@lgh = lgh_number,
		@stp_type = stp_type
	from inserted
	
	--if stp_number is null then this must be a delete
	if @stp is null
		select @stp = stp_number,
			@ord = ord_hdrnumber,
			@mov = mov_number,
			@lgh = lgh_number,
			@stp_type = stp_type,
			@delete = 'Y'
		from deleted

	select @outstatus = lgh_outstatus,
		@lgh_dsp_date = lgh_dsp_date,
		@trc = lgh_tractor 
	from legheader 
	where lgh_number = @lgh

	--only send order based changes to the tractor and if a load assignment was sent
	-- 	and not complete or AVL
	if @ord > 0 and @stp_type in ('PUP','DRP') and @trc <> 'UNKNOWN' and
		@lgh_dsp_date is not null and @outstatus not in ('AVL','CMP','PLN')
	begin
		--check stop insert/delete cmp id change first and skip date check if it occurs
		if (update(cmp_id) or @delete = 'Y') and @TMailStopChangeFormID > 0 --update(cmp_id) will be true for inserts
		begin --send @TMailStopChangeFormID	
			insert TMSQLMessage (msg_date, msg_FormID, msg_To, msg_ToType, msg_FilterData,
				msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
			values (getdate(), 
				@TMailStopChangeFormID, 
				@trc, 
				4, --type 4 tractor
				@trc+convert(varchar(5),@TMailStopChangeFormID)+convert(varchar(15),@lgh), --filter duolicate rows
				30, --wait 30 seconds
				@tmwuser,
				0, --0 who knows
				'Stop Information Change')
	
			insert TMSQLMessageData (msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
			values (@@identity, 1, 'lgh_number', @lgh)
		end
		else if (update(stp_schdtearliest) or update(stp_schdtlatest)) and @TMailDateChgForm > 0
		begin --send @TMailDateChgForm
			insert TMSQLMessage (msg_date, msg_FormID, msg_To, msg_ToType, msg_FilterData,
				msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
			values (getdate(), 
				@TMailDateChgForm, 
				@trc, 
				4, --type 4 tractor
				@trc+convert(varchar(5),@TMailDateChgForm)+convert(varchar(15),@stp), --filter duolicate rows
				30, --wait 30 seconds
				@tmwuser,
				0, --0 who knows
				'Stop Date Time Change')
	
			insert TMSQLMessageData (msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
			values (@@identity, 1, 'StopNumber', @stp)
		end
	end
end

END

--PTS34310 jg end logic(DELETE) relocated from iutd_stops_tmail_updates
----------------------------------------------------------------------------------


/* EXECUTE timerins "dt_stops", "END" */

-- RE - PTS77738 - BEGIN
UPDATE	legheader
   SET	lgh_optimizationdate = GETDATE()
  FROM	deleted 
 WHERE	legheader.lgh_number = deleted.lgh_number
-- RE - PTS77738 - END

-- RE - PTS86385 - BEGIN
UPDATE	tractorprofile
   SET	trc_optimizationdate = GETDATE()
  FROM	deleted d
			INNER JOIN legheader lgh ON lgh.lgh_number =  d.lgh_number
 WHERE	tractorprofile.trc_number = lgh.lgh_tractor
   AND	tractorprofile.trc_number <> 'UNKNOWN'
-- RE - PTS86385 - END
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  CREATE TRIGGER [dbo].[it_stops_consolidated] ON [dbo].[stops] FOR INSERT AS   
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/**
 *
 * NAME:
 * dbo.del_notes
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * The insert trigger for the stops table
 *
 * REFERENCES:
 * none
 *
 * REVISION HISTORY:
  12/29/00 PTS 9625 dpete remove existing auto214 code, no current need for 214 on added stop.  
         Might find that adding a completed stop needs auto 214, but wait to see.  
  DPETE PTS14202 6/11/02 Make sure referencenumber has the ord_hdrnumber field populated  
  DPETE PTS 16846 TMI Decides they want image records for orders with assets only
  DPETE PTS 17833 TMI now wants record for empty moves
 * 08/02/2005.01 - Vince Herman ? add spt_lastupdatebydepart and stp_lastupdatedatedepart
 * 09/26/2006.01 - PTS34310 - JG - consolidate and optimize trigger.
 *                 "Insert" logic in iut_pallet_tracking_stops, iut_stops_createpurchaseservice, iutd_stops_tmail_updates,
 *                 and it_stops were consolidated into this trigger.
  06-01-2007 BPISK PTS37339 Added TMIImageTripStatus to generalinfo for user defined codes
 * 3/17/09 DPETE 46570 REPLACE OLD OUTER JOIN
 * PMILL 42166/49873 11/6/2009 added FlyingJ imaging vendor
 * MCURN 49233 06/11/14 Removed update of updatedby updateddt from trigger. Put into a Def Constraint instead.
*/  

/* EXEC timerins 'it_stops', 'START' */  
  
BEGIN  
  
  
DECLARE	@ord_hdrnumber		int,  
	@stp_cmp_id		varchar(8),  
	@stp_number		int,
	@stp_transfer_type	varchar(3),
	@TMAgentID		varchar(255),
	@TMAgentReplacement	varchar(255),
	@v_evt_type		varchar(6),
	@count			int,
	@stp_status		VARCHAR(3),
	@stp_event		VARCHAR(6),
	@mov_num		INT,
	@lgh_num		INT,
	@stp_arrivaldate	DATETIME,
	@ord_billto		VARCHAR(8),
	@cityname 		VARCHAR(18),
	@eat_id			INTEGER

--PTS34310 prevent empty firing
if not exists (select 1 from inserted) return
--PTS34310 end

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

----------------------------------------------------------------------------------
--PTS34310 jg begin logic(INSERT) relocated from iut_stops_createpurchaseservice
----------------------------------------------------------------------------------
DECLARE @eventcode varchar(6),
        @purchaseservice char(1),
        @stpnumber int,
        @cmdcode varchar(8),
        @lghnumber int,
        @cmpid varchar(8),
        @ordhdr int,
        @dropdt datetime,
        @pickupdt datetime,
        --PTS 55626 JJF 20110816
        --@pshid varchar(15),
        @pshid varchar(17),
        --END PTS 55626 JJF 20110816
        @ordnumber varchar(12),
        @nextletter varchar(26),
        @cmdpscount int,
        @cmppscount int,
        @pocount int,
        @pochar char(1),
        @pshnumber int,
        @movnumber int,
	@pshvendorid varchar(8),
	@fgt_refnum varchar(30),
--        @count int,
        @trl_id varchar(13),
	@max_psh_number int,
	@ascii	int

SELECT @nextletter = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

SELECT @eventcode = stp_event,
                  @stpnumber = stp_number,
                  @cmdcode = cmd_code,
                  @lghnumber = lgh_number,
                  @cmpid = cmp_id,
                  @ordhdr = ord_hdrnumber,
                  @dropdt = stp_arrivaldate,
                  @pickupdt = DATEADD(hour, 6, stp_departuredate),
                  @movnumber = mov_number,
                  @pshnumber = psh_number,
                  @trl_id = trl_id
     FROM inserted

IF @eventcode is null /* Must be a delete */
BEGIN
     SELECT @eventcode = stp_event,
                       @stpnumber = stp_number,
                       @cmdcode = cmd_code,
                       @lghnumber = lgh_number,
                       @cmpid = cmp_id,
                       @ordhdr = ord_hdrnumber,
                       @dropdt = stp_arrivaldate,
                       @pickupdt = DATEADD(hour, 6, stp_departuredate),
                       @movnumber = mov_number,
                       @pshnumber = psh_number,
                       @trl_id = trl_id
         FROM deleted
     IF @pshnumber > 0
     BEGIN
          DELETE FROM purchaseservicedetail 
               WHERE psh_number = @pshnumber
          DELETE FROM purchaseserviceheader
               WHERE psh_number = @pshnumber
     END
END
ELSE
BEGIN
     IF Update(stp_event)
     BEGIN
          SELECT @purchaseservice = ect_purchase_service
              FROM eventcodetable
           WHERE abbr = @eventcode
          IF @purchaseservice IS NOT NULL AND @purchaseservice = 'Y'
          BEGIN
               IF @ordhdr = 0 
               BEGIN
                   /* PTS17481 MBR 03/05/03 */
                   SELECT @ordhdr = ord_hdrnumber
                     FROM stops
                    WHERE mov_number = @movnumber AND
                          stp_type = 'PUP'
               END
               --PTS87300 MBR 03/30/15 Must be an empty move.  If trailer is not unknown
               --find last drop stop for trailer from previous trips to get the move and order number.
               IF @ordhdr = 0 AND @trl_id <> 'UNKNOWN'
               BEGIN
                  SET @movnumber = 0
                  SELECT TOP 1 @movnumber = evt_mov_number,
                               @ordhdr = ord_hdrnumber
                    FROM event
                   WHERE evt_trailer1 = @trl_id AND
                         evt_status = 'DNE' AND
                         evt_pu_dr = 'DRP' AND
                         evt_sequence = 1 AND
                         ord_hdrnumber > 0
                  ORDER BY evt_startdate DESC 
                END
               SELECT @pshvendorid = thirdpartyprofile.tpr_id
                 FROM thirdpartyprofile, company
                WHERE tpr_id = @cmpid  AND
                      tpr_id = cmp_id AND
                      cmp_service_location = 'Y' AND
					  ISNULL(cmp_service_location_own, 'N') = 'N'
               IF @pshvendorid is not null 
               BEGIN
                    SELECT @cmppscount = count(*)
                      FROM vendorpurchaseservices
                     WHERE cmp_id = @cmpid
                    DECLARE cmd_cursor CURSOR FOR
                         SELECT DISTINCT cmd_code, fgt_refnum
                           FROM freightdetail
                          WHERE freightdetail.stp_number IN (SELECT stp_number
                                                               FROM stops
                                                              WHERE mov_number = @movnumber AND
                                                                    stp_type = 'PUP')
                    OPEN cmd_cursor
                    FETCH NEXT FROM cmd_cursor INTO @cmdcode, @fgt_refnum
                    SET @count = 1
                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                         SELECT @cmdpscount = count(*)
                             FROM commoditypurchaseservices
                          WHERE cmd_code = @cmdcode
                         IF @cmppscount > 0 or @cmdpscount > 0 
                         BEGIN
                              IF @count = 1
                              BEGIN
                                   /* PTS17481 MBR 03/05/03 */
                                   SELECT @ordnumber = ord_hdrnumber
                                     FROM stops
                                    WHERE mov_number = @movnumber AND
                                          stp_type = 'PUP'
                                   --PTS16704 MBR 12/31/02
							   SELECT @max_psh_number = IsNull(Max(psh_number), 0)
								 FROM purchaseserviceheader
								WHERE ord_hdrnumber = @ordhdr
								--PTS 55626 JJF 20110816
								IF EXISTS	(	SELECT	*
												FROM	generalinfo
												WHERE	gi_name = 'PurchaseServiceNumbering'
														and gi_string1 = '1'
											) BEGIN

									SELECT	@pshid =	CASE CHARINDEX('-', psh_id, 1)
															WHEN 0 THEN RIGHT(psh_id, 1)
															ELSE SUBSTRING(psh_id, CHARINDEX('-', psh_id, 1) + 1, LEN(psh_id))
														END
									FROM 	purchaseserviceheader
									WHERE	psh_number = @max_psh_number
									
									SELECT @pshid = ISNULL(@pshid, '')
									
									IF len(@pshid) = 0 BEGIN
										SELECT	@pshid = RTRIM(@ordnumber) + '-0001'
									END
									ELSE IF len(@pshid) = 1 BEGIN
										SELECT	@ascii = ASCII(RIGHT(@pshid,1))
										SELECT	@ascii = @ascii + 1
										SELECT	@pochar = CHAR(@ascii)
										SELECT	@pshid = RTRIM(@ordnumber) + @pochar
									END
									ELSE BEGIN
										--Since we are in a trigger, would rather not block update due to max service records...
										IF CONVERT(int, @pshid) >= 9999 BEGIN
											SELECT @pshid = RTRIM(@ordnumber) + '-9999'
										END
										ELSE BEGIN
											SELECT	@pshid = RTRIM(@ordnumber) + '-' + RIGHT('0000' + CONVERT(varchar(4), CONVERT(int, @pshid) + 1), 4)
										END
									END
								END
									
								ELSE BEGIN
									IF @max_psh_number > 0 BEGIN
										SELECT	@pshid = psh_id
										FROM	purchaseserviceheader
										WHERE	psh_number = @max_psh_number

										SELECT	@ascii = ASCII(RIGHT(@pshid,1))
										SELECT	@ascii = @ascii + 1
										SELECT	@pochar = CHAR(@ascii)
										SELECT	@pshid = RTRIM(@ordnumber) + @pochar
									END
									ELSE BEGIN
										SELECT @pochar = 'A'
										SELECT @pshid = RTRIM(@ordnumber) + @pochar
									END
								END

							   --IF @max_psh_number > 0
							   --BEGIN
							   --   SELECT @pshid = psh_id
							   --     FROM purchaseserviceheader
							   --    WHERE psh_number = @max_psh_number
							   --   SELECT @ascii = ASCII(RIGHT(@pshid,1))
							   --   SELECT @ascii = @ascii + 1
							   --   SELECT @pochar = CHAR(@ascii)
							   --   SELECT @pshid = RTRIM(@ordnumber) + @pochar
							   --END
							   --ELSE
							   --BEGIN
							   --   SELECT @pochar = 'A'
							   --   SELECT @pshid = RTRIM(@ordnumber) + @pochar
							   --END
							   --END PTS 55626 JJF 20110816                                   
									EXECUTE @pshnumber = getsystemnumber 'PURCHSRV',''
                                   INSERT INTO purchaseserviceheader (psh_id, psh_number, psh_status, psh_vendor_id, 
                                                                      psh_drop_dt, psh_pickup_dt, psh_promised_dt, 
                                                                      ord_hdrnumber, psh_service, stp_number, trl_id)
                                                              values (@pshid, @pshnumber, 'HLD', @pshvendorid, @dropdt,
                                                                      @pickupdt,@pickupdt, @ordhdr, @eventcode, 
                                                                      @stpnumber, @trl_id)
                                   SET @count = 2
                              END
                              INSERT INTO purchaseservicedetail (psh_number, psd_type, psd_qty, psd_estrate, psd_heelqty,
                                                                 psd_rate, cmd_code, fgt_refnum)
                              SELECT @pshnumber, psd_type, 1, cps_estrate, 1, 0, @cmdcode, @fgt_refnum
                               FROM commoditypurchaseservices
                              WHERE cmd_code = @cmdcode
                         END
                         FETCH NEXT FROM cmd_cursor INTO @cmdcode, @fgt_refnum
                     END
                    CLOSE cmd_cursor
                    DEALLOCATE cmd_cursor
                    UPDATE purchaseservicedetail
                       SET purchaseservicedetail.psd_estrate = vendorpurchaseservices.vps_estrate
                      FROM purchaseservicedetail, vendorpurchaseservices
                     WHERE purchaseservicedetail.psh_number = @pshnumber AND
                           purchaseservicedetail.psd_type = vendorpurchaseservices.psd_type AND
                           vendorpurchaseservices.cmp_id = @pshvendorid
                    UPDATE stops SET psh_number = @pshnumber
                         WHERE stp_number = @stpnumber
               END
          END
     END
     IF UPDATE(cmp_id) and @pshnumber > 0 
     BEGIN
          UPDATE purchaseserviceheader
                   SET psh_vendor_id = @cmpid,
                             psh_drop_dt = @dropdt,
                             psh_pickup_dt = @pickupdt,
                             psh_promised_dt = @pickupdt
           WHERE psh_number = @pshnumber
     END
END

--PTS34310 jg end logic(INSERT) relocated from iut_stops_createpurchaseservice
----------------------------------------------------------------------------------



----------------------------------------------------------------------------------
--PTS34310 jg begin logic(INSERT) relocated from iutd_stops_tmail_updates
----------------------------------------------------------------------------------

-- trigger for PTS12969 send info to TMail when order changes

declare @TMailDateChgForm int, 
	@TMailStopChangeFormID int,
	@ord int, @mov int, @lgh int, @stp int, @temp varchar(60),
	@delete char(1), @stp_type varchar(6), @trc varchar(8),
	@outstatus varchar(6), @lgh_dsp_date datetime

--PTS34310 begin multi-row delete handling logic
--only run for singe row updates
--if (select count(*) from inserted) > 1 or
--	(select count(*) from deleted) > 1 Return
if NOT ( (select count(*) from inserted) > 1 or
	(select count(*) from deleted) > 1 )
BEGIN
--PTS34310 end multi-row delete handling logic

select @TMailDateChgForm = 0, @TMailStopChangeFormID = 0 

select @temp = gi_string1 from generalinfo
where gi_name = 'TMailDateChangeFormID'
if isnumeric(@temp) = 1 select @TMailDateChgForm = convert(int, @temp)

select @temp = gi_string1 from generalinfo
where gi_name = 'TMailStopChangeFormID'
if isnumeric(@temp) = 1 select @TMailStopChangeFormID = convert(int, @temp)

--make sure one of the option are turned on
if @TMailDateChgForm + @TMailStopChangeFormID > 0
begin
	select @delete = 'N'

	select @stp = stp_number,
		@ord = ord_hdrnumber,
		@mov = mov_number,
		@lgh = lgh_number,
		@stp_type = stp_type
	from inserted
	
	--if stp_number is null then this must be a delete
	if @stp is null
		select @stp = stp_number,
			@ord = ord_hdrnumber,
			@mov = mov_number,
			@lgh = lgh_number,
			@stp_type = stp_type,
			@delete = 'Y'
		from deleted

	select @outstatus = lgh_outstatus,
		@lgh_dsp_date = lgh_dsp_date,
		@trc = lgh_tractor 
	from legheader 
	where lgh_number = @lgh

	--only send order based changes to the tractor and if a load assignment was sent
	-- 	and not complete or AVL
	if @ord > 0 and @stp_type in ('PUP','DRP') and @trc <> 'UNKNOWN' and
		@lgh_dsp_date is not null and @outstatus not in ('AVL','CMP','PLN')
	begin
		--check stop insert/delete cmp id change first and skip date check if it occurs
		if (update(cmp_id) or @delete = 'Y') and @TMailStopChangeFormID > 0 --update(cmp_id) will be true for inserts
		begin --send @TMailStopChangeFormID	
			insert TMSQLMessage (msg_date, msg_FormID, msg_To, msg_ToType, msg_FilterData,
				msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
			values (getdate(), 
				@TMailStopChangeFormID, 
				@trc, 
				4, --type 4 tractor
				@trc+convert(varchar(5),@TMailStopChangeFormID)+convert(varchar(15),@lgh), --filter duolicate rows
				30, --wait 30 seconds
				@tmwuser,
				0, --0 who knows
				'Stop Information Change')
	
			insert TMSQLMessageData (msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
			values (@@identity, 1, 'lgh_number', @lgh)
		end
		else if (update(stp_schdtearliest) or update(stp_schdtlatest)) and @TMailDateChgForm > 0
		begin --send @TMailDateChgForm
			insert TMSQLMessage (msg_date, msg_FormID, msg_To, msg_ToType, msg_FilterData,
				msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
			values (getdate(), 
				@TMailDateChgForm, 
				@trc, 
				4, --type 4 tractor
				@trc+convert(varchar(5),@TMailDateChgForm)+convert(varchar(15),@stp), --filter duolicate rows
				30, --wait 30 seconds
				@tmwuser,
				0, --0 who knows
				'Stop Date Time Change')
	
			insert TMSQLMessageData (msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
			values (@@identity, 1, 'StopNumber', @stp)
		end
	end
end

END

--PTS34310 jg end logic(INSERT) relocated from iutd_stops_tmail_updates
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
--PTS34310 jg begin logic in old it_stops trigger
----------------------------------------------------------------------------------

-- vjh 32460 - copy cmp_revtype4 to stp_unload_paytype

if (SELECT substring(upper(gi_string1),1,1)   
 FROM generalinfo  
 WHERE gi_name = 'CmpRevType4Copy')='Y' 


	if (select count(*)  
	 from inserted i
	 where i.cmp_id <> 'UNKNOWN') > 0
	begin  
	 update stops   
	 set stp_unload_paytype = cmp_revtype4  
	      from inserted i, company  
	 where i.cmp_id <> 'UNKNOWN' and   
	  i.cmp_id = company.cmp_id and
	  (i.stp_number = stops.stp_number)  
	end  


--PTS 23691 CGK 9/3/2004
--DECLARE @tmwuser varchar (255)
--exec gettmwuser @tmwuser output


SELECT @ord_hdrnumber = ord_hdrnumber,  
 @stp_cmp_id = cmp_id,  
 @stp_number = stp_number FROM inserted  
  
/* MF   insert generalinfo (gi_name, gi_string1)  
     values ('MakeCityCmp', 'YES') */  
  
if (SELECT substring(upper(gi_string1),1,1)   
 FROM generalinfo  
 WHERE gi_name = 'MakeCityCmp')='Y' and  
  @ord_hdrnumber > 0 and (substring(@stp_cmp_id,1,1)='_' or @stp_cmp_id='UNKNOWN')  
    exec makecitycmpid @stp_number  
  
  
/* PTS 7557 - make sure stp_city and cmp city are the same*/  
if (select count(*)  
 from inserted i, company  
 where i.cmp_id <> 'UNKNOWN' and   
  i.cmp_id = company.cmp_id and  
  i.stp_city <> company.cmp_city) > 0  
begin  
 update stops   
 set stp_city = cmp_city  
      from inserted i, company  
 where i.cmp_id <> 'UNKNOWN' and   
  i.cmp_id = company.cmp_id and  
  i.stp_city <> company.cmp_city and  
  (i.stp_number = stops.stp_number)  
end  
  
  
/*Insert a row into the dispaudit table when the stp_custpickupdate and stp_custdeliverydate are not null when a record  
  is inserted and the generalinfo setting FingerprintAudit is set to Y.*/  
  
if (select upper(substring(gi_string1,1,1)) from generalinfo  
       where gi_name = 'FingerprintAudit') = 'Y'  
begin  
	Select @cityname=c.cty_name from city as c, inserted as i where c.cty_code = i.stp_city
	--DPH PTS 25147 10/13/04
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,mov_number
			,lgh_number
			,join_to_table_name
			,key_value)
	select 	i.ord_hdrnumber
			,@tmwuser
			,'Stop Inserted'
			,getdate()
			,i.stp_event + '(' + i.cmp_id + ',' + @cityname + ')'   -- PTS 63061
			,isnull(mov_number, 0)
			,i.lgh_number
			,'stops'
			,convert(varchar(100), stp_number)
	from	inserted i
	--DPH PTS 25147 10/13/04


   declare @pickup_date datetime,  
              @delivery_date datetime,  
--            @ord int,  
              @leg int,  
              @stop int,  
              @cmp_name varchar(30),  
              @event  varchar(6),  
              @city varchar(25)  
  
   select @pickup_date = stp_custpickupdate,  
             @delivery_date = stp_custdeliverydate  
     from inserted  
  
   if @pickup_date is not null  
   begin  
      select @ord = ord_hdrnumber,  
                @leg = lgh_number,  
                @stop = stp_number,  
                @event = stp_event  
        from inserted  
      set @cmp_name = (select cmp_name from company where cmp_id = (select cmp_id from inserted))  
      set @city = (select cty_nmstct from city where cty_code = (select stp_city from inserted))  
      insert into dispaudit (ord_hdrnumber, lgh_number, updated_by, updated_dt, stp_number,  
                                    new_req_pickup_dt, stp_event, cty_nmstct, cmp_name)  
                      values    (@ord, @leg, @tmwuser, getdate(), @stop, @pickup_date,  
                                    @event, @city, @cmp_name)  
   end  
  
   if @delivery_date is not null  
   begin  
      select @ord = ord_hdrnumber,  
                @leg = lgh_number,  
                @stop = stp_number,  
                @event = stp_event  
        from inserted  
      set @cmp_name = (select cmp_name from company where cmp_id = (select cmp_id from inserted))  
      set @city = (select cty_nmstct from city where cty_code = (select stp_city from inserted))  
      insert into dispaudit (ord_hdrnumber, lgh_number, updated_by, updated_dt, stp_number,  
                                    new_req_delivery_dt, stp_event, cty_nmstct, cmp_name)  
                      values    (@ord, @leg, @tmwuser, getdate(), @stop, @delivery_date,  
                                    @event, @city, @cmp_name)  
  
   end
   
   --PTS62991 MBR 10/11/12
   IF (SELECT UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
        FROM generalinfo
       WHERE gi_name = 'UseTripAudit') = 'Y'
   BEGIN

      INSERT INTO expedite_audit (ord_hdrnumber, updated_by, activity, updated_dt, update_note,
                                  mov_number, lgh_number, join_to_table_name, key_value)
         SELECT i.ord_hdrnumber,
                @tmwuser,
                'Arrive Status',
                getdate(),
                CASE i.stp_status
                   WHEN 'DNE' THEN	'Arrived ' + i.stp_event + '(' + i.cmp_id + ' - ' + ISNULL(c.cty_name, 'UNKNOWN') + ',' + ISNULL(c.cty_state, 'UNKNOWN')  + ') ' + CONVERT(VARCHAR(16), i.stp_arrivaldate, 120)
                   WHEN 'OPN' THEN 'Initial Arrival ' + i.stp_event + '(' + i.cmp_id + ' - ' + ISNULL(c.cty_name, 'UNKNOWN') + ',' + ISNULL(c.cty_state, 'UNKNOWN')  + ') ' + CONVERT(VARCHAR(16), i.stp_arrivaldate, 120)
                END,
                i.mov_number,
                i.lgh_number,
                'stops',
                CONVERT(VARCHAR(100), i.stp_number)
           FROM inserted i LEFT OUTER JOIN city c ON c.cty_code = i.stp_city
          WHERE i.stp_status IN ('OPN','DNE')

      SET @eat_id = SCOPE_IDENTITY()
      IF @eat_id > 0
      BEGIN
         INSERT INTO expedite_audit_arrival_departure (expedite_audit_ident, eaad_datetime)
            SELECT @eat_id, getdate()
              FROM inserted
      END

      INSERT INTO expedite_audit (ord_hdrnumber, updated_by, activity, updated_dt, update_note,
                                  mov_number, lgh_number, join_to_table_name, key_value)
         SELECT i.ord_hdrnumber,
                @tmwuser,
                'Depart Status',
                getdate(),
                CASE i.stp_departure_status
                   WHEN 'DNE' THEN	'Departed ' + i.stp_event + '(' + i.cmp_id + ' - ' + ISNULL(c.cty_name, 'UNKNOWN') + ',' + ISNULL(c.cty_state, 'UNKNOWN')  + ') ' + CONVERT(VARCHAR(16), i.stp_departuredate, 120)
                   WHEN 'OPN' THEN 'Initial Departure ' + i.stp_event + '(' + i.cmp_id + ' - ' + ISNULL(c.cty_name, 'UNKNOWN') + ',' + ISNULL(c.cty_state, 'UNKNOWN')  + ') ' + CONVERT(VARCHAR(16), i.stp_departuredate, 120)
                END,
                i.mov_number,
                i.lgh_number,
                'stops',
                CONVERT(VARCHAR(100), i.stp_number)
           FROM inserted i LEFT OUTER JOIN city c ON c.cty_code = i.stp_city
          WHERE i.stp_departure_status IN ('OPN','DNE')

      SET @eat_id = SCOPE_IDENTITY()
      IF @eat_id > 0
      BEGIN
         INSERT INTO expedite_audit_arrival_departure (expedite_audit_ident, eaad_datetime)
            SELECT @eat_id, getdate()
              FROM inserted
      END
   END
end 

/*PTS43038 MBR 06/04/08*/
UPDATE stops
   SET stp_origarrival = i.stp_arrivaldate
  FROM inserted i
 WHERE stops.stp_number = i.stp_number 

/* PTS15189 MBR 8/13/02 */
/* PTS 24458 CGK 12/10/2004 Commented and put code in ps_n_order_stops
SELECT @stp_transfer_type = stp_transfer_type
     FROM inserted
IF @stp_transfer_type = 'SIT'
BEGIN
     UPDATE orderheader
              SET ord_status = 'SIT'
       WHERE ord_hdrnumber = @ord_hdrnumber AND
                         ord_status <> 'SIT'
END*/

--PTS# 15477 add code to write the ord_hdrnumber to table ImageOrderList for TMI 
--           Imaging
IF EXISTS (SELECT gi_string1
			 FROM generalinfo
			WHERE (gi_name = 'ImagingVendorOnRoad' Or gi_name = 'ImagingVendorInHouse') AND IsNull(gi_string1,'') in ('TMI','FLYINGJ'))	--pmill 42166/49873 added flyingJ
BEGIN
--PTS37339 begin
     declare @tripPakStatus varchar(256);

     select @tripPakStatus  = coalesce(gi_string1,'DSP,STD,CMP,ICO') from generalinfo where gi_name = 'TMIImageTripStatus'

     if (@tripPakStatus is null or ltrim(@tripPakStatus) = '')
         set @tripPakStatus = 'DSP,STD,CMP,ICO';

     set @tripPakStatus = ',' + @tripPakStatus + ',';

	If Exists (	Select ord_hdrnumber from inserted
		Where inserted.ord_hdrnumber > 0 )
		Insert Into ImageOrderList (ord_hdrnumber)
		Select distinct ord_hdrnumber from inserted
		Where inserted.ord_hdrnumber > 0 
		and not exists (select ord_hdrnumber from ImageOrderList i Where i.ord_hdrnumber = inserted.ord_hdrnumber)
		And exists (Select ord_status from orderheader o where o.ord_hdrnumber = inserted.ord_hdrnumber and 0 < charindex(',' + o.ord_status + ',', @tripPakStatus))
--PTS37339 end
 	Else
	begin
--		Insert Into ImageMoveList (mov_number)
--		Select distinct mov_number From Inserted
--		Where inserted.ord_hdrnumber = 0
--		and not exists (select mov_number from ImageMoveList i Where  i.mov_number = inserted.mov_number )
--		and exists (Select  lgh_outstatus from legheader Where mov_number = inserted.mov_number and lgh_outstatus in ('DSP','STD','CMP'))
--		and not exists (Select stp_event From stops s Where s.Mov_number = inserted.mov_number and s.Ord_hdrnumber > 0) 	   
		declare	@ordcount	int,
				@legcount	int,
				@min		int

		select	@min = min(mov_number)
		from	inserted
		where	ord_hdrnumber = 0

		while isnull(@min, -1) > -1
		begin
			select @ordcount = count(mov_number) from stops where mov_number = @min and ord_hdrnumber <> 0

			if @ordcount = 0
			begin
				select @legcount = count(mov_number) from legheader where mov_number = @min and lgh_outstatus in ('DSP','STD','CMP')

				if @legcount > 0 
				begin
					if (select count(mov_number) from imagemovelist where mov_number = @min) = 0
					begin
						insert into imagemovelist (mov_number) values (@min)
					end
				end
			end

			select	@min = min(mov_number)
			  from	inserted
			 where	ord_hdrnumber = 0 and
					mov_number > @min
		end
	end
END
--PTS# 15477

--PTS33896 MBR 09/06/06
IF (SELECT UPPER(SUBSTRING(gi_string1, 1, 1)) 
      FROM generalinfo 
     WHERE gi_name = 'TrailerSpotting') = 'Y'
BEGIN
   SELECT @stp_status = i.stp_status,
          @stp_event = i.stp_event,
          @stp_number = i.stp_number,
          @mov_num = i.mov_number,
          @lgh_num = i.lgh_number,
          @stp_arrivaldate = i.stp_arrivaldate,
          @ord_hdrnumber = i.ord_hdrnumber,
          @trl_id = i.trl_id,
          @ord_billto = Orderheader.ord_billto
     FROM inserted i
     left outer join orderheader on i.ord_hdrnumber = orderheader.ord_hdrnumber
   
   IF @stp_status = 'DNE' AND @stp_event = 'DRL'
   BEGIN
      EXEC create_trailerspottingdetail @stp_number, @mov_num, @lgh_num, @ord_hdrnumber, @stp_arrivaldate, @ord_billto, @trl_id
   END
END

 
/*****************************************************************************
	PTS 51051 - <<BEGIN>> MDH - Add container expiration processing
******************************************************************************/
DECLARE	@exp_key				INTEGER
DECLARE	@dt_start_date			DATETIME,
		@dt_ins_date			DATETIME,
		@dt_estimated			DATETIME
DECLARE @InService				VARCHAR (12),
		@IntermodalMode			CHAR (1),
		@ins_stp_status			CHAR (6),
		@cmp_port				CHAR (1)

SELECT @InService = ISNULL (LEFT (gi_string3, 12), 'No Change'),
       @IntermodalMode = ISNULL (LEFT (gi_String1, 1), 'N')
	FROM generalinfo
	WHERE gi_name = 'IntermodalMode'

IF @IntermodalMode = '2'
BEGIN
	SELECT @stp_cmp_id = ISNULL(i.cmp_id,'UNKNOWN'),
			@cmp_port = ISNULL (cmp_port, 'N'),
			@trl_id = ISNULL (trl_id, 'UNKNOWN'), @dt_start_date = stp_arrivaldate ,
			@dt_estimated = stp_schdtearliest,
			@ins_stp_status = stp_status
		FROM inserted i left join company on i.cmp_id = company.cmp_id
		WHERE stp_number = @stp_number

	/* Give up if trl_id is UNKNOWN */
	IF @inservice ='NO CHANGE' 
		SET @inservice = 'NOCHANGE'
	IF @trl_id <> 'UNKNOWN' AND @cmp_port = 'Y' AND @inservice <> 'NoChange'
	BEGIN
		/* Update inservice expiration based on pickup, if it exists */
		SELECT @dt_ins_date = @dt_estimated
		IF (@inservice = 'OUTGATE' OR @inservice = 'OUT GATE') AND @ins_stp_status = 'DNE'
		BEGIN
			SELECT @dt_ins_date = @dt_start_date
		END 
		SELECT @exp_key = MAX (exp_key)
			FROM expiration
			WHERE exp_idtype = 'TRL'
			  AND exp_id = @trl_id
			  AND exp_code = 'INS'
		IF @exp_key IS NOT NULL
			UPDATE expiration
				SET exp_expirationdate   = @dt_ins_date,
					exp_compldate		 = @dt_ins_date,
					exp_updateby         = dbo.gettmwuser_fn(),
				    exp_updateon         = CURRENT_TIMESTAMP
		    WHERE exp_key = @exp_key
	END /* @trl_id <> 'UNKNOWN' AND (@inservice <> 'NoChange' OR @inservice <> 'NO CHANGE') */
END /* If Intermodal Mode 2 and certain fields updated */

/*****************************************************************************
	PTS 51051 - <<END>> MDH - container expiration processing
******************************************************************************/ 

-- RE - PTS77738 - BEGIN
UPDATE	stops
   SET	stp_optimizationdate = GETDATE()
  FROM	inserted
 WHERE	stops.stp_number = inserted.stp_number
-- RE - PTS77738 - END

-- RE - PTS86385 - BEGIN
UPDATE	tractorprofile
   SET	trc_optimizationdate = GETDATE()
  FROM	inserted i
			INNER JOIN legheader lgh ON lgh.lgh_number = i.lgh_number
 WHERE	tractorprofile.trc_number = lgh.lgh_tractor
   AND	tractorprofile.trc_number <> 'UNKNOWN'
 -- RE - PTS86385 - END

/*SKIP TRIGGER CODE FOR NEW DISPATCH ONLY IS EXECUTED IF SKIP_TRIGGER COLUMN  
 IS SET TO 1*/  
declare @skip_trigger int  
select @skip_trigger = count(*)  
from inserted where skip_trigger = 1  
if @skip_trigger > 0   
begin  
 UPDATE stops    
    SET skip_trigger = 0  
      FROM inserted  
     WHERE (inserted.stp_number = stops.stp_number)  
      
 return  
end  
  
DECLARE  @recnum   int,  
  @refseq   int,  
    @ord_hdr  int,  
  @lgh_number  int,  
  @mov_number  int,  
  @refnum   varchar(30),  
--@cmdcode  varchar(8),  
   @dd    varchar(12),  
  @evt   char(6),  
--@stp_type  varchar(6),  
  @cmp_id   varchar(8),  
  @dprtdate  datetime,  
  @arvdate  datetime  
     
     
/* VARIABLE @stp_number  IS USED IN MANY PLACES INITIALIZE IT HERE */  
SELECT  @stp_number =  inserted.stp_number,  
 @ord_hdr = inserted.ord_hdrnumber,  
 @evt = inserted.stp_event,  
 @stp_type = inserted.stp_type,  
 @cmp_id = inserted.cmp_id,  
 @lgh_number = inserted.lgh_number,  
 @mov_number = inserted.mov_number,  
 @arvdate = inserted.stp_arrivaldate,  
 @dprtdate = inserted.stp_departuredate  
FROM inserted  
  
IF @dprtdate >= '20491231' OR @dprtdate < @arvdate  
 SELECT @dprtdate = @arvdate  

/********************************************************************************  
  LOG INSERTED STOPS IF LogRouteMods OPTION IS YES  
*********************************************************************************/  
  
IF ((select count(*)   
 FROM generalinfo, orderheader  
 WHERE generalinfo.gi_name = 'LogRouteMods' AND    
         generalinfo.gi_string1 = 'YES'   and  
  orderheader.ord_hdrnumber =  @ord_hdr ) > 0)   
   
 BEGIN   
 INSERT INTO trip_modification_log    
         ( ord_hdrnumber,     
           stp_number,              tml_date,     
           tml_event,     
           stp_event,     
           cmp_id,     
           user_id,     
           tml_revtype1,     
           tml_revtype2,     
           tml_revtype3,     
           tml_revtype4,     
           stp_sequence,     
           stp_reftype,     
           stp_refnum,     
           ord_number,     
           ord_subcompany,     
           tml_orderby,  
    stp_schdtearliest,  
    stp_schdtlatest,  
    stp_arrivaldate,  
    stp_departuredate )    
  select @ord_hdr,     
           @stp_number,     
            getdate(),     
            'ADD',     
            @evt,     
            inserted.cmp_id,     
            @tmwuser,  
            orderheader.ord_revtype1,     
            orderheader.ord_revtype2,     
            orderheader.ord_revtype3,     
            orderheader.ord_revtype4,     
            inserted.stp_sequence,     
            inserted.stp_reftype,     
            inserted.stp_refnum,     
            orderheader.ord_number,               orderheader.ord_subcompany,     
            orderheader.ord_company,  
    inserted.stp_schdtearliest,  
    inserted.stp_schdtlatest,  
    @arvdate,  
    @dprtdate  
 FROM inserted, orderheader, labelfile WHERE orderheader.ord_hdrnumber = inserted.ord_hdrnumber and  
  orderheader.ord_status = labelfile.abbr and  
  labelfile.labeldefinition = 'DispStatus' and  
  labelfile.code between 200 and 400  
  
 END  
  
  
  
/********************************************************************************  
  UPDATE EVENTS  
*********************************************************************************/  
  
 /* Insert an event row */  
IF ( Select Count (*) from inserted, event   
 where event.stp_number = inserted.stp_number AND event.evt_sequence = 1 ) = 0  
 BEGIN  
-- RE - 02/12/02 - PTS #13312 Start  
 SELECT @recnum = ISNULL(tmp_evt_number, 0) FROM inserted  
  
 IF @recnum = 0 exec @recnum = getsystemnumber 'EVTNUM', ''     
-- RE - 02/12/02 - PTS #13312 End  
  
 INSERT INTO event   
  ( ord_hdrnumber, stp_number, evt_eventcode, evt_startdate,   
   evt_enddate, evt_earlydate, evt_latedate,  
   evt_pu_dr, evt_driver1, evt_driver2, evt_tractor,  
   evt_trailer1, evt_trailer2, evt_chassis, evt_dolly,   
   evt_carrier, evt_number, evt_sequence, evt_status )  
  
 SELECT  @ord_hdr, @stp_number, @evt, @arvdate,  
  @dprtdate, stp_schdtearliest, stp_schdtlatest,  
  stp_type, 'UNKNOWN','UNKNOWN','UNKNOWN',  
  'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN',  
  @recnum, 1, stp_status  
 FROM inserted   
-- RE - 02/12/02 - PTS #13312 Start   
-- IF ( @evt ) = 'HLT' AND  
--  ( @ord_hdr ) > 0  
--  BEGIN  
--  /* Insert an event row for Preload  */  
--  exec @recnum = getsystemnumber 'EVTNUM', ''     
--  
--  INSERT INTO event   
--   ( ord_hdrnumber, stp_number, evt_eventcode, evt_startdate,   
--    evt_enddate, evt_earlydate, evt_latedate,  
--    evt_pu_dr, evt_driver1, evt_driver2, evt_tractor,  
--    evt_trailer1, evt_trailer2, evt_chassis, evt_dolly,   
--    evt_carrier, evt_number, evt_sequence, evt_status )  
--   
--  SELECT  @ord_hdr, @stp_number, 'PLD', @arvdate,  
--     @dprtdate, stp_schdtearliest, stp_schdtlatest,  
--     stp_type, 'UNKNOWN','UNKNOWN','UNKNOWN',  
--     'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN',  
--     @recnum, 2, stp_status  
--  
--  FROM inserted   
--  END   
--  
-- IF ( @evt ) = 'DLT' AND  
--  ( @ord_hdr ) > 0  
--  BEGIN  
--  /* Insert an event row for PostUnload  */  
--  exec @recnum = getsystemnumber 'EVTNUM', ''     
--  
--  INSERT INTO event   
--   ( ord_hdrnumber, stp_number, evt_eventcode, evt_startdate,   
--    evt_enddate, evt_earlydate, evt_latedate,  
--    evt_pu_dr, evt_driver1, evt_driver2, evt_tractor,  
--  
--    evt_trailer1, evt_trailer2, evt_chassis, evt_dolly,   
--    evt_carrier, evt_number, evt_sequence, evt_status )  
--   
--  SELECT  @ord_hdr, @stp_number, 'PUL', @arvdate,  
--   @dprtdate, stp_schdtearliest, stp_schdtlatest,  
--   stp_type, 'UNKNOWN','UNKNOWN','UNKNOWN',  
--   'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN',  
--   @recnum, 2, stp_status  
--  
--  FROM inserted   
--  END   
-- RE - 02/12/02 - PTS #13312 End  
 DECLARE @def_evts int, @counter int, @seqno int  
 SELECT @def_evts = 0, @counter = 0  
 SELECT @def_evts = count(*) FROM eventdefaults, inserted  
 WHERE inserted.cmp_id = eventdefaults.cmp_id  
 WHILE @counter < @def_evts  
 BEGIN  
  SELECT @counter = @counter + 1  
  SELECT @seqno = @counter + 2  
  EXEC @recnum = getsystemnumber 'EVTNUM', ''  
  /*JLB 29394 add condition for default SAP events
  INSERT INTO event  
   ( ord_hdrnumber, stp_number, evt_eventcode, evt_startdate,  
    evt_enddate, evt_earlydate, evt_latedate,   
    evt_pu_dr, evt_number, evt_sequence, evt_status)  
  
   SELECT  @ord_hdr, @stp_number, evd_eventcode, @arvdate,  
    @dprtdate, stp_schdtearliest, stp_schdtlatest,  
    stp_type, @recnum, @seqno, stp_status  
   FROM inserted, eventdefaults  
   WHERE inserted.cmp_id = eventdefaults.cmp_id AND  
    evd_seq = @counter AND  
    inserted.stp_type IN ( 'PUP', 'DRP' )  
*/
  select @v_evt_type = isnull(eventdefaults.evd_eventcode,'')
    from eventdefaults
    join inserted on inserted.cmp_id = eventdefaults.cmp_id
   where eventdefaults.evd_seq = @counter
  if @v_evt_type <> 'SAP'
     begin
      INSERT INTO event  
      ( ord_hdrnumber, stp_number, evt_eventcode, evt_startdate,  
       evt_enddate, evt_earlydate, evt_latedate,   
       evt_pu_dr, evt_number, evt_sequence, evt_status)  
     
      SELECT  @ord_hdr, @stp_number, evd_eventcode, @arvdate,  
       @dprtdate, stp_schdtearliest, stp_schdtlatest,  
       stp_type, @recnum, @seqno, stp_status  
      FROM inserted, eventdefaults  
      WHERE inserted.cmp_id = eventdefaults.cmp_id AND  
       evd_seq = @counter AND  
       inserted.stp_type IN ( 'PUP', 'DRP' )  
     end  
  else  --SAP event  needs inital appointment info
    begin
      INSERT INTO event  
      ( ord_hdrnumber, stp_number, evt_eventcode, evt_startdate,  
       evt_enddate, evt_earlydate, evt_latedate,   
       evt_pu_dr, evt_number, evt_sequence, evt_status, evt_contact, evt_reason)  
     
      SELECT  @ord_hdr, @stp_number, evd_eventcode, @arvdate,  
       @dprtdate, stp_schdtearliest, stp_schdtlatest,  
       stp_type, @recnum, @seqno, stp_status, 'Inital Appointment', 'INIT'  
      FROM inserted, eventdefaults  
      WHERE inserted.cmp_id = eventdefaults.cmp_id AND  
       evd_seq = @counter AND  
       inserted.stp_type IN ( 'PUP', 'DRP' )  
    end
  --end 29394
 END
 END  
ELSE   
 BEGIN  
 UPDATE event  
 SET evt_status = stp_status,  
  evt_startdate = @arvdate,  
  evt_earlydate = stp_schdtearliest,  
  evt_latedate = stp_schdtlatest  
 FROM inserted  
 WHERE ( evt_status <> stp_status OR  
  evt_startdate <> @arvdate OR  
  evt_earlydate <> stp_schdtearliest OR  
  evt_latedate <> stp_schdtlatest ) AND  
  inserted.stp_number = event.stp_number  
  
/* the following is a jam to fire the event trigger in the case */  
/* where the event is added before the stop in the trip folder */  
/* and the trailer is filled in on the event */  
/* Since there is no insert event trigger, the trailer asgn records would otherwise   */  
/* be created */  
  
 UPDATE event  
 SET evt_trailer1 = evt_trailer1,  
  evt_trailer2 = evt_trailer2  
 FROM inserted WHERE inserted.stp_number = event.stp_number AND  
  evt_trailer1 <> 'UNKNOWN'   
  
 END  
  
/********************************************************************************  
  UPDATE REFERENCE NUMBERS  
*********************************************************************************/  
  
 /* INSERT INITIAL REFERENCE NUMBER IF NOT NULL */  
 IF ( Select Count (*) from referencenumber   
  where referencenumber.ref_tablekey = @stp_number AND   
   referencenumber.ref_table = 'stops' AND  
   referencenumber.ref_sequence = 1 ) = 0  
  BEGIN  
  INSERT INTO referencenumber ( ref_tablekey, ref_type, ref_number, ref_sequence, ref_table ,ord_hdrnumber)  
  SELECT @stp_number, stp_reftype, stp_refnum, 1, 'stops',ord_hdrnumber  
  FROM inserted   
  WHERE inserted.stp_refnum IS NOT null or inserted.stp_refnum <> ''  
  END  
/********************************************************************************  
  UPDATE FREIGHT DETAIL  
*********************************************************************************/  
/* LOR PTS#3913 add volume and volumeunit  */  
  
 /* Insert a fgt row. IT IS POSSIBLE THAT THE FREIGTH DETAIL MAY HAVE ALREADY  
  BEEN CREATED ON TEH CLIENT */  
  
 /* OLD METHOD */  
 /* if (select count(*) from freightdetail   
  where stp_number = @stp_number and  
   fgt_sequence= 1) = 0 */  
 /* 8070 no need to add freight detail by trigger Order Entry & Vdisp do */  
 /* NEW METHOD THE STOPS FROM THE COMMIDTY SCREEN MODE WILL BE MARKED   
 IF ((SELECT ISNULL(MAX(stp_screenmode), 'a') from inserted) <> 'COMMOD')  
   BEGIN  
   EXEC @recnum = getsystemnumber 'FGTNUM', ''     
   INSERT INTO freightdetail   
    (stp_number,  
    fgt_number,   
    cmd_code,  
    fgt_weight,  
    fgt_weightunit,  
    fgt_description,  
    fgt_count,  
    fgt_countunit,   
    fgt_sequence,  
    fgt_reftype ,  
    cht_itemcode,     
            fgt_charge,     
            fgt_quantity,  
    fgt_volume,   
    fgt_volumeunit)   
  
   SELECT  
    stp_number,  
    @recnum,  
    cmd_code,  
    stp_weight,  
    stp_weightunit,  
    stp_description,  
    stp_count,  
    stp_countunit,  
    1,  
    'REF',  
    'UNK',  
    0,  
    0,  
    stp_volume,  
    stp_volumeunit  
   FROM inserted    
  END  
  
         */  
/********************************************************************************  
  UPDATE LOCATION INFORMATION  
*********************************************************************************/  
  
 UPDATE stops    
    SET stp_state = city.cty_state  
 FROM city    
 WHERE ( stops.stp_city = city.cty_code ) AND  
   ( @stp_number = stops.stp_number)  
  
 -- pts6419 defaults replaced rather than adjusted in new proc  
 --EXEC default_loadrequirements @ord_hdr, @stp_number, @cmp_id, @stp_type, @lgh_number, @mov_number  
     
 /* EXEC timerins 'it_stops', 'END' */  
END  


UPDATE stops
SET stops.stp_detstatus=0 --vjh 26457 now set to 0 (gray) when departure actualized
FROM inserted
WHERE inserted.stp_number = stops.stp_number
	--AND inserted.stp_detstatus=2 vjh 26457 from any status
	AND (inserted.stp_status='OPN' OR inserted.stp_departure_status = 'DNE')
	and stops.stp_detstatus <> 0
  

--PTS34310 jg end logic in old it_stops trigger
----------------------------------------------------------------------------------

--select * from dhl_orderexport

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_stops_consolidated] ON [dbo].[stops] FOR UPDATE  
AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF NOT EXISTS (SELECT 1 FROM inserted)
  RETURN;

DECLARE @inserted                     UtStopsConsolidated,
        @deleted                      UtStopsConsolidated,
        @UseTripAudit                 CHAR(1),
        @FingerprintAudit             CHAR(1),
        @OrderEventExport             CHAR(1),
        @MaptuitAlert                 CHAR(1),
        @TrailerSpotting              CHAR(1),
        @LoadFileExport               CHAR(1),
        @ComputeCBPProcessingFlag     CHAR(1),
        @IntermodalMode               CHAR(1),
        @InService                    VARCHAR(12),
        @SELate                       CHAR(1),
        @SELateDepart                 CHAR(1),
        @SEAsset                      VARCHAR(6),
        @PurchaseServiceNumbering     CHAR(1),
        @Auto214Flag                  CHAR(1),
        @EDI214ApptTrigger            CHAR(1),
        @EDINotificationProcessType   INTEGER,
        @SlackTime                    INTEGER,
        @MakeCityCmp                  CHAR(1),
        @ImagingVendorOnRoad          VARCHAR(60),
        @ImagingVendorInHouse         VARCHAR(60),
        @TripPakStatus                VARCHAR(60),
        @AddSecondaryLoadUnloadEvents VARCHAR(60),
        @TMGeocodingFormId					  INTEGER,
        @CBPDefaultStrategy           VARCHAR(100),
        @TMGeocodingDeliverTo        VARCHAR(15),
        @tmwuser                      VARCHAR(255),
        @GETDATE                      DATETIME,
        @TMailStopChangeFormID        INTEGER,
        @TMailDateChangeFormID        INTEGER,
        @TMAgentID                    VARCHAR(255),
        @TMAgentReplacement           VARCHAR(255),
        @StpStatusChanged             CHAR(1),
        @StpDepartureStatusChanged    CHAR(1),
        @StpArrived                   CHAR(1),
        @StpDeparted                  CHAR(1),
        @StpArrivalDateChanged        CHAR(1),
        @StpDepartureDateChanged      CHAR(1),
        @StpReasonLateChanged         CHAR(1),
        @StpReasonLateDepartChanged   CHAR(1),
        @CmpIdChanged                 CHAR(1),
        @StpCityChanged               CHAR(1),
        @StpCountryChanged            CHAR(1),
        @StpSchdtEarliestChanged      CHAR(1),
        @PsTrlIdChanged               CHAR(1),
        @PsStpEventChanged            CHAR(1),
        @PsCmpIdChanged               CHAR(1),
        @OrdHdrNumberChanged          CHAR(1),
        @LghNumberChanged             CHAR(1),
        @StpDetStatusChanged          CHAR(1),
        @StpEventChanged              CHAR(1),
        @StpSchdtLatestChanged        CHAR(1),
        @StpMfhSequenceChanged        CHAR(1),
        @StpOptimizationDateChanged   CHAR(1),
        @SkipTrigger                  CHAR(1),
        @HPLAdded                     CHAR(1),
        @HPLRemoved                   CHAR(1),
        @DRLAdded                     CHAR(1),
        @DRLRemoved                   CHAR(1),
        @CmdCodeChanged               CHAR(1),
        @StpDescriptionChanged        CHAR(1),
        @StpWeightChanged             CHAR(1),
        @StpWeightunitChanged         CHAR(1),
        @StpCountChanged              CHAR(1),
        @StpCountunitChanged          CHAR(1),
        @StpVolumeChanged             CHAR(1),
        @StpVolumeunitChanged         CHAR(1),
        @StpPalletsInChanged          CHAR(1),
        @StpPalletsOutChanged         CHAR(1),
        @StpRefNumChanged             CHAR(1),
        @StpRefTypeChanged            CHAR(1),
        @stp_number                   INTEGER,
        @cmp_id                       VARCHAR(8),
        @execcommand                  NVARCHAR(4000),
        @TripPakStatusTable           TMWTable_char6;
        
DECLARE @StopsList  TABLE (stp_number INTEGER NOT NULL PRIMARY KEY);

SELECT  @FingerprintAudit = CASE 
                              WHEN gi_name = 'FingerprintAudit' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                              ELSE @FingerprintAudit
                            END,
        @UseTripAudit = CASE
                          WHEN gi_name = 'UseTripAudit' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                          ELSE @UseTripAudit
                        END,
        @OrderEventExport = CASE
                              WHEN gi_name = 'OrderEventExport' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                              ELSE @OrderEventExport
                            END,
        @MaptuitAlert = CASE
                          WHEN gi_name = 'MaptuitAlert' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                          ELSE @MaptuitAlert
                        END,
        @TMailStopChangeFormID = CASE
                                   WHEN gi_name = 'TMailStopChangeFormID' THEN CASE ISNUMERIC(gi_string1)
                                                                                 WHEN 1 THEN CONVERT(INTEGER, gi_string1)
                                                                                 ELSE 0
                                                                               END
                                   ELSE @TMailStopChangeFormID
                                 END,
        @TMailDateChangeFormID = CASE
                                   WHEN gi_name = 'TMailDateChangeFormID' THEN CASE ISNUMERIC(gi_string1)
                                                                                 WHEN 1 THEN CONVERT(INTEGER, gi_string1)
                                                                                 ELSE 0
                                                                               END
                                   ELSE @TMailDateChangeFormID
                                 END,
        @TrailerSpotting = CASE 
                             WHEN gi_name = 'TrailerSpotting' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                             ELSE @TrailerSpotting
                           END,
        @TMAgentID = CASE
                       WHEN gi_name = 'TotalMailAgentID' THEN COALESCE(gi_string1 , '')
                       ELSE @TMAgentID
                     END,
        @TMAgentReplacement = CASE
                                WHEN gi_name = 'TotalMailAgentID' THEN COALESCE(gi_string2 , 'NoReplacementSpecified')
                                ELSE @TMAgentReplacement
                              END,
        @LoadFileExport = CASE
                            WHEN gi_name = 'LoadFileExport' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                            ELSE @LoadFileExport
                          END,
        @ComputeCBPProcessingFlag = CASE
                                      WHEN gi_name = 'ComputeCBPProcessingFlag' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                                      ELSE @ComputeCBPProcessingFlag
                                    END,
        @IntermodalMode = CASE
                            WHEN gi_name = 'IntermodalMode' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                            ELSE @IntermodalMode
                          END,
        @InService = CASE
                       WHEN gi_name = 'IntermodalMode' THEN LEFT(COALESCE(gi_string3, 'NOCHANGE'), 12)
                       ELSE @InService
                     END,
        @SELate = CASE
                    WHEN gi_name = 'AutoCreateLateServiceException' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                    ELSE @SELate
                  END,
        @SELateDepart = CASE
                          WHEN gi_name = 'AutoCreateLateServiceException' THEN LEFT(COALESCE(gi_string2, 'N'), 1)
                          ELSE @SELateDepart
                        END,
        @SEAsset = CASE 
                     WHEN gi_name = 'AutoCreateLateServiceException' THEN LEFT(COALESCE(gi_string3, ''), 6)
                     ELSE @SEAsset
                   END,
        @PurchaseServiceNumbering = CASE
                                      WHEN gi_name = 'PurchaseServiceNumbering' THEN LEFT(COALESCE(gi_string1, '1'), 1)
                                      ELSE @PurchaseServiceNumbering
                                    END,
        @Auto214Flag = CASE 
                         WHEN gi_name = 'Auto214Flag' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                         ELSE @Auto214Flag
                       END,
        @EDI214ApptTrigger = CASE
                               WHEN gi_name = 'EDI214ApptTrigger' THEN LEFT(COALESCE(gi_string1 , 'T'), 1)
                               ELSE @EDI214ApptTrigger
                             END,
        @EDINotificationProcessType = CASE
                                        WHEN gi_name = 'EDI_Notification_Process_Type' THEN CASE ISNUMERIC(gi_string1)
                                                                                              WHEN 1 THEN CONVERT(INTEGER, gi_string1)
                                                                                              ELSE 0
                                                                                            END
                                        ELSE @EDINotificationProcessType
                                      END,
        @SlackTime = CASE
                       WHEN gi_name = 'SlackTime' THEN CASE ISNUMERIC(gi_string1)
                                                         WHEN 1 THEN CONVERT(INTEGER, gi_string1)
                                                         ELSE 0
                                                       END
                       ELSE @SlackTime
                     END,
        @MakeCityCmp = CASE
                         WHEN gi_name = 'MakeCityCmp' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
                         ELSE @MakeCityCmp
                       END,
        @ImagingVendorOnRoad = CASE   
                                 WHEN gi_name = 'ImagingVendorOnRoad' THEN COALESCE(gi_string1, '')
                                 ELSE @ImagingVendorOnRoad
                               END,
        @ImagingVendorInHouse = CASE
                                  WHEN gi_name = 'ImagingVendorInHouse' THEN COALESCE(gi_string1, '')
                                  ELSE @ImagingVendorInHouse
                                END,
        @TripPakStatus = CASE
                           WHEN gi_name = ',' + 'TMIImageTripStatus' THEN COALESCE(NULLIF(gi_string1, ''), 'DSP,STD,CMP,ICO') + ','
                           ELSE @TripPakStatus
                         END,
        @AddSecondaryLoadUnloadEvents = CASE
                                          WHEN gi_name = 'AddSecondaryLoadUnloadEvents' THEN COALESCE(gi_string1, '')
                                          ELSE @AddSecondaryLoadUnloadEvents
                                        END,
        @TMGeocodingFormId = CASE
                                WHEN gi_name = 'TMGeocoding' THEN CASE ISNUMERIC(gi_string1)
                                                                     WHEN 1 THEN CONVERT(INTEGER, gi_string1)
                                                                     ELSE 0
                                                                   END
                                ELSE @TMGeocodingFormId
                              END,
        @TMGeocodingDeliverTo = CASE 
                                   WHEN gi_name = 'TMGeocoding' THEN LEFT(COALESCE(gi_string2, ''), 15)
                                   ELSE @TMGeocodingDeliverTo
                                 END,
        @CBPDefaultStrategy = CASE 
                                WHEN gi_name = 'CBPDefaultStrategy' THEN gi_string1
                                ELSE @CBPDefaultStrategy
                              END
  FROM  generalinfo WITH(NOLOCK)
 WHERE  gi_name IN ('FingerprintAudit', 'UseTripAudit', 'OrderEventExport', 'MaptuitAlert',
                    'TMailStopChangeFormID', 'TMailDateChangeFormID', 'TrailerSpotting',
                    'TotalMailAgentID', 'LoadFileExport', 'ComputeCBPProcessingFlag',
                    'IntermodalMode', 'AutoCreateLateServiceException', 'PurchaseServiceNumbering',
                    'Auto214Flag', 'EDI214ApptTrigger', 'EDI_Notification_Process_Type', 'SlackTime',
                    'MakeCityCmp', 'ImagingVendorOnRoad', 'ImagingVendorInHouse', 'TMIImageTripStatus',
                    'AddSecondaryLoadUnloadEvents', 'TMGeoCoding', 'CBPDefaultStrategy');

SELECT  @FingerprintAudit = COALESCE(@FingerprintAudit, 'N'),
        @UseTripAudit = COALESCE(@UseTripAudit, 'N'),
        @OrderEventExport = COALESCE(@OrderEventExport, 'N'),
        @MaptuitAlert = COALESCE(@MaptuitAlert, 'N'),
        @TMailDateChangeFormID = COALESCE(@TMailDateChangeFormID, 0),
        @TMailStopChangeFormID = COALESCE(@TMailStopChangeFormID, 0),
        @TrailerSpotting = COALESCE(@TrailerSpotting, 'N'),
        @TMAgentID = COALESCE(@TMAgentID, ''),
        @LoadFileExport = COALESCE(@LoadFileExport, 'N'),
        @ComputeCBPProcessingFlag = COALESCE(@ComputeCBPProcessingFlag, 'N'),
        @IntermodalMode = COALESCE(@IntermodalMode, 'N'),
        @InService = CASE
                       WHEN @InService = 'NO CHANGE' THEN 'NOCHANGE'
                       ELSE COALESCE(@InService, 'NOCHANGE')
                     END,
        @SELate = COALESCE(@SELate, 'N'),
        @SELateDepart = CASE
                          WHEN COALESCE(@SELate, 'N') = 'N' THEN 'N'
                          ELSE COALESCE(@SELateDepart, 'N')
                        END,
        @SEAsset = COALESCE(@SEAsset, ''),
        @PurchaseServiceNumbering = COALESCE(@PurchaseServiceNumbering, '1'),
        @Auto214Flag = CASE
                         WHEN APP_NAME() = 'TMWDX' THEN 'N'
                         ELSE COALESCE(@Auto214Flag, 'N')
                       END,
        @EDI214ApptTrigger = COALESCE(@EDI214ApptTrigger, 'T'),
        @SlackTime = COALESCE(@SlackTime, 0),
        @MakeCityCmp = COALESCE(@MakeCityCmp, 'N'),
        @ImagingVendorOnRoad = COALESCE(@ImagingVendorOnRoad, ''),
        @ImagingVendorInHouse = COALESCE(@ImagingVendorInHouse, ''),
        @TripPakStatus = COALESCE(@TripPakStatus, ',DSP,STD,CMP,ICO,'),
        @AddSecondaryLoadUnloadEvents = COALESCE(@AddSecondaryLoadUnloadEvents, ''),
        @TMGeocodingFormId = COALESCE(@TMGeocodingFormId, 0),
        @TMGeocodingDeliverTo = COALESCE(@TMGeocodingDeliverTo, ''),
        @StpStatusChanged = 'N',
        @StpDepartureStatusChanged = 'N',
        @StpArrived = 'N',
        @StpDeparted = 'N',
        @StpArrivalDateChanged = 'N',
        @StpDepartureDateChanged = 'N',
        @StpReasonLateChanged = 'N',
        @StpReasonLateDepartChanged = 'N',
        @CmpIdChanged = 'N',
        @StpCountryChanged = 'N',
        @StpSchdtEarliestChanged = 'N',
        @PsTrlIdChanged = 'N',
        @PsStpEventChanged = 'N',
        @PsCmpIdChanged = 'N',
        @StpCityChanged = 'N',
        @OrdHdrNumberChanged = 'N',
        @LghNumberChanged = 'N',
        @StpDetStatusChanged = 'N',
        @StpEventChanged = 'N',
        @StpSchdtLatestChanged = 'N',
        @StpMfhSequenceChanged = 'N',
        @StpOptimizationDateChanged = 'N',
        @SkipTrigger = 'N',
        @HPLAdded = 'N',
        @HPLRemoved = 'N',
        @DRLAdded = 'N',
        @DRLRemoved = 'N',
        @CmdCodeChanged = 'N',
        @StpDescriptionChanged = 'N',
        @StpWeightChanged = 'N',
        @StpWeightunitChanged = 'N',
        @StpCountChanged = 'N',
        @StpCountunitChanged = 'N',
        @StpVolumeChanged = 'N',
        @StpVolumeunitChanged = 'N',
        @StpPalletsInChanged = 'N',
        @StpPalletsOutChanged = 'N',
        @StpRefNumChanged = 'N',
        @StpRefTypeChanged = 'N',
        @CBPDefaultStrategy = COALESCE(@CBPDefaultStrategy, '');

INSERT INTO @TripPakStatusTable
  SELECT value FROM dbo.CSVStringsToTable_fn(@TripPakStatus)

INSERT INTO @inserted
  SELECT  stp_number,
          mov_number,
          lgh_number,
          ord_hdrnumber,
          stp_mfh_sequence,
          stp_sequence,
          stp_event,
          stp_type,
          stp_arrivaldate,
          stp_departuredate,
          stp_status,
          stp_departure_status,
          stp_schdtearliest,
          stp_schdtlatest,
          stp_custpickupdate,
          stp_custdeliverydate,
          stp_eta,
          cmp_id,
          stp_city,
          stp_state,
          stp_country,
          stp_reasonlate,
          stp_reasonlate_text,
          stp_reasonlate_depart,
          stp_reasonlate_depart_text,
          cmd_code,
          stp_podname,
          stp_comment,
          trl_id,
          psh_number,
          stp_detstatus,
          last_updatedate,
          last_updateby,  
          last_updatedatedepart,
          last_updatebydepart,
          stp_optimizationdate,
          stp_refnum,
          stp_reftype,
          stp_description,
          stp_weight,
          stp_weightunit,
          stp_count,
          stp_countunit,
          stp_volume,
          stp_volumeunit,
          stp_pallets_in,
          stp_pallets_out,
          skip_trigger
    FROM  inserted;

INSERT INTO @deleted
  SELECT  stp_number,
          mov_number,
          lgh_number,
          ord_hdrnumber,
          stp_mfh_sequence,
          stp_sequence,
          stp_event,
          stp_type,
          stp_arrivaldate,
          stp_departuredate,
          stp_status,
          stp_departure_status,
          stp_schdtearliest,
          stp_schdtlatest,
          stp_custpickupdate,
          stp_custdeliverydate,
          stp_eta,
          cmp_id,
          stp_city,
          stp_state,
          stp_country,
          stp_reasonlate,
          stp_reasonlate_text,
          stp_reasonlate_depart,
          stp_reasonlate_depart_text,
          cmd_code,
          stp_podname,
          stp_comment,
          trl_id,
          psh_number,
          stp_detstatus,
          last_updatedate,
          last_updateby,  
          last_updatedatedepart,
          last_updatebydepart,
          stp_optimizationdate,
          stp_refnum,
          stp_reftype,
          stp_description,
          stp_weight,
          stp_weightunit,
          stp_count,
          stp_countunit,
          stp_volume,
          stp_volumeunit,
          stp_pallets_in,
          stp_pallets_out,
          skip_trigger
    FROM  deleted;

EXEC dbo.gettmwuser @tmwuser OUTPUT;
SET @tmwuser = UPPER(@tmwuser);

SET @GETDATE = GETDATE();

SELECT  @StpStatusChanged = CASE 
                              WHEN COALESCE(i.stp_status, '') <> COALESCE(d.stp_status, '') THEN 'Y'
                              ELSE @StpStatusChanged
                            END,
        @StpDepartureStatusChanged = CASE 
                                       WHEN COALESCE(i.stp_departure_status, '') <> COALESCE(d.stp_departure_status, '') THEN 'Y'
                                       ELSE @StpDepartureStatusChanged
                                     END,
        @StpArrived = CASE
                        WHEN COALESCE(i.stp_status, '') <> COALESCE(d.stp_status, '') AND COALESCE(i.stp_status, '') = 'DNE' THEN 'Y'
                        ELSE @StpArrived
                      END,
        @StpDeparted = CASE
                         WHEN COALESCE(i.stp_departure_status, '') <> COALESCE(d.stp_departure_status, '') AND COALESCE(i.stp_departure_status, '') = 'DNE' THEN 'Y'
                         ELSE @StpDeparted
                       END,
        @StpArrivalDateChanged = CASE
                                   WHEN COALESCE(i.stp_arrivaldate, CONVERT(DATETIME, 0)) <> COALESCE(d.stp_arrivaldate, CONVERT(DATETIME, 0))  THEN 'Y'
                                   ELSE @StpArrivalDateChanged
                                 END,
        @StpDepartureDateChanged = CASE
                                     WHEN COALESCE(i.stp_departuredate, CONVERT(DATETIME, 0)) = COALESCE(d.stp_departuredate, CONVERT(DATETIME, 0)) THEN 'Y'
                                     ELSE @StpDepartureDateChanged
                                   END,
        @StpReasonLateChanged = CASE
                                  WHEN COALESCE(i.stp_reasonlate, 'NULL') <> COALESCE(d.stp_reasonlate, 'NULL') THEN 'Y'
                                  ELSE @StpReasonLateChanged
                                END,
				@StpReasonLateDepartChanged = CASE
																				WHEN COALESCE(i.stp_reasonlate_depart, 'NULL') <> COALESCE(d.stp_reasonlate_depart, 'NULL') THEN 'Y'
																				ELSE @StpReasonLateDepartChanged
																		  END,
        @CmpIdChanged = CASE 
                          WHEN COALESCE(i.cmp_id, '') <> COALESCE(d.cmp_id, '') THEN 'Y'
                          ELSE @CmpIdChanged
                        END,
        @StpCountryChanged = CASE
                               WHEN COALESCE(i.stp_country, '') <> COALESCE(d.stp_country, '') THEN 'Y'
                               ELSE @StpCountryChanged
                              END,
        @StpSchdtEarliestChanged = CASE
                                     WHEN COALESCE(i.stp_schdtearliest, CONVERT(DATETIME, 0)) <> COALESCE(d.stp_schdtearliest, CONVERT(DATETIME, 0)) THEN 'Y'
                                     ELSE @StpSchdtEarliestChanged
                                   END,
        @PsTrlIdChanged = CASE
                             WHEN COALESCE(i.trl_id, 'UNKNOWN') <> COALESCE(d.trl_id, 'UNKNOWN') AND i.psh_number > 0 THEN 'Y'
                             ELSE @PsTrlIdChanged
                           END,
        @PsStpEventChanged = CASE
                             WHEN COALESCE(i.stp_event, '') <> COALESCE(d.stp_event, '') AND COALESCE(ect.ect_purchase_service, 'N') = 'Y' THEN 'Y'
                             ELSE @PsStpEventChanged
                           END,
        @PsCmpIdChanged = CASE 
                            WHEN COALESCE(i.cmp_id, '') <> COALESCE(d.cmp_id, '') AND COALESCE(i.psh_number, 0) > 0 THEN 'Y'
                            ELSE @PsCmpIdChanged
                          END,
        @StpCityChanged = CASE
                            WHEN COALESCE(i.stp_city, 0) <> COALESCE(d.stp_city, 0) THEN 'Y'
                            ELSE @StpCityChanged
                          END,
        @OrdHdrNumberChanged = CASE
                                 WHEN COALESCE(i.ord_hdrnumber, 0) <> COALESCE(d.ord_hdrnumber, 0) THEN 'Y'
                                 ELSE @OrdHdrNumberChanged
                               END,
        @LghNumberChanged = CASE  
                              WHEN COALESCE(i.lgh_number, 0) <> COALESCE(d.lgh_number,0) THEN 'Y'
                              ELSE @LghNumberChanged
                            END,
        @StpDetStatusChanged = CASE
                                 WHEN COALESCE(i.stp_detstatus, -1) <> COALESCE(d.stp_detstatus, -1) THEN 'Y'
                                 ELSE @StpDetStatusChanged
                               END,
        @StpEventChanged = CASE
                             WHEN COALESCE(i.stp_event, '') <> COALESCE(d.stp_event, '') THEN 'Y'
                             ELSE @StpEventChanged
                           END,
        @StpSchdtLatestChanged = CASE
                                   WHEN COALESCE(i.stp_schdtlatest, CONVERT(DATETIME, 0)) <> COALESCE(d.stp_schdtlatest, CONVERT(DATETIME, 0)) THEN 'Y'
                                   ELSE @StpSchdtLatestChanged
                                 END,
        @StpMfhSequenceChanged = CASE
                                   WHEN COALESCE(i.stp_mfh_sequence, -1) <> COALESCE(d.stp_mfh_sequence, -1) THEN 'Y'
                                   ELSE @StpMfhSequenceChanged
                                 END,
        @StpOptimizationDateChanged = CASE
                                        WHEN COALESCE(i.stp_optimizationdate, CONVERT(DATETIME, 0)) <> COALESCE(d.stp_optimizationdate, CONVERT(DATETIME, 0)) THEN 'Y'
                                        ELSE @StpOptimizationDateChanged
                                      END,
        @SkipTrigger = CASE
                         WHEN COALESCE(i.skip_trigger, 0) = 1 THEN 'Y'
                         ELSE @SkipTrigger
                       END,
        @HPLAdded = CASE 
                      WHEN COALESCE(i.stp_event, '') = 'HPL' AND COALESCE(d.stp_event, '') <> 'HPL' THEN 'Y'
                      ELSE @HPLAdded
                    END,
        @HPLRemoved = CASE 
                        WHEN COALESCE(i.stp_event, '') <> 'HPL' AND COALESCE(d.stp_event, '') = 'HPL' THEN 'Y'
                        ELSE @HPLRemoved
                      END,
        @DRLAdded = CASE 
                      WHEN COALESCE(i.stp_event, '') = 'DRL' AND COALESCE(d.stp_event, '') <> 'DRL' THEN 'Y'
                      ELSE @DRLAdded
                    END,
        @DRLRemoved = CASE 
                        WHEN COALESCE(i.stp_event, '') <> 'DRL' AND COALESCE(d.stp_event, '') = 'DRL' THEN 'Y'
                        ELSE @DRLRemoved
                      END,
        @CmdCodeChanged = CASE
                            WHEN COALESCE(i.cmd_code, '') <> COALESCE(d.cmd_code, '') THEN 'Y'
                            ElSE @CmdCodeChanged
                          END,
        @StpDescriptionChanged = CASE
                                   WHEN COALESCE(i.stp_description , '') <> COALESCE(d.stp_description, '') THEN 'Y'
                                   ELSE @StpDescriptionChanged
                                 END,
        @StpWeightChanged = CASE
                              WHEN COALESCE(i.stp_weight, 0) <> COALESCE(d.stp_weight, 0) THEN 'Y'
                              ELSE @StpWeightChanged
                            END,
        @StpWeightunitChanged = CASE
                                  WHEN COALESCE(i.stp_weightunit, '') <> COALESCE(d.stp_weightunit, '') THEN 'Y'
                                  ELSE @StpWeightunitChanged
                                END,
        @StpCountChanged = CASE
                             WHEN COALESCE(i.stp_count, 0) <> COALESCE(d.stp_count, 0) THEN 'Y'
                             ELSE @StpCountChanged
                           END,
        @StpCountunitChanged = CASE
                                 WHEN COALESCE(i.stp_countunit, '') <> COALESCE(d.stp_countunit, '') THEN 'Y'
                                 ELSE @StpCountunitChanged
                               END,
        @StpVolumeChanged = CASE
                              WHEN COALESCE(i.stp_volume, 0) <> COALESCE(d.stp_volume, 0) THEN 'Y'
                              ELSE @StpVolumeChanged
                             END,
        @StpVolumeUnitChanged = CASE
                                  WHEN COALESCE(i.stp_volumeunit, '') <> COALESCE(d.stp_volumeunit, '') THEN 'Y'
                                  ELSE @StpVolumeUnitChanged
                                END,
        @StpPalletsInChanged = CASE
                                 WHEN COALESCE(i.stp_pallets_in, 0) <> COALESCE(d.stp_pallets_in, 0) THEN 'Y'
                                 ELSE @StpPalletsInChanged
                               END,
        @StpPalletsOutChanged = CASE
                                 WHEN COALESCE(i.stp_pallets_out, 0) <> COALESCE(d.stp_pallets_out, 0) THEN 'Y'
                                 ELSE @StpPalletsoutChanged
                               END,
        @StpRefNumChanged = CASE
                              WHEN COALESCE(i.stp_refnum, '') <> COALESCE(d.stp_refnum, '') THEN 'Y'
                              ELSE @StpRefNumChanged
                            END,
        @StpRefTypeChanged = CASE
                               WHEN COALESCE(i.stp_reftype, '') <> COALESCE(d.stp_reftype, '') THEN 'Y'
                               ELSE @StpRefTypeChanged
                             END
  FROM  @inserted i 
          INNER JOIN @deleted d ON d.stp_number = i.stp_number
          INNER JOIN dbo.eventcodetable ect WITH(NOLOCK) ON ect.abbr = i.stp_event

IF @FingerprintAudit = 'Y'
  EXECUTE dbo.UtStopsConsolidated_FingerprintAudit_sp @inserted, @deleted, @tmwuser, @GETDATE, @UseTripAudit;

IF @StpStatusChanged = 'Y'
BEGIN
  IF @OrderEventExport = 'Y' AND @StpArrived = 'Y'
    EXECUTE dbo.UtStopsConsolidated_OrderEventExport_sp @inserted, @deleted;

  IF @TrailerSpotting = 'Y'
    EXECUTE dbo.UtStopsConsolidated_TrailerSpotting_sp @inserted, @deleted

  IF EXISTS(SELECT 1 FROM @inserted i INNER JOIN dbo.compinvprofile c ON c.cmp_id = i.cmp_id)
    EXECUTE dbo.UtStopsConsolidated_DipHistory_sp @inserted, @deleted;
END

IF @MaptuitAlert = 'Y' AND (@StpArrived = 'Y' OR @StpDeparted = 'Y')
  EXECUTE dbo.UtStopsConsolidated_MaptuitAlert_sp @inserted, @deleted, @GETDATE;

-- Delete trigger on freight_by_compartment doesn't handle multiple row updates
DELETE FROM dbo.freight_by_compartment
 WHERE mov_number IN (SELECT  d.mov_number
                        FROM  @inserted i
                                INNER JOIN @deleted d ON d.stp_number = i.stp_number
                       WHERE  i.mov_number <> d.mov_number);

IF (@TMailDateChangeFormID + @TMailStopChangeFormID) > 0
  EXECUTE dbo.UtStopsConsolidated_TMailChangeForms_sp @inserted, @deleted, @tmwuser, @GETDATE, @TMailStopChangeFormID, @TMailDateChangeFormID;

IF @StpStatusChanged = 'Y' OR @StpArrivalDateChanged = 'Y' OR @StpDepartureStatusChanged = 'Y' OR @StpDepartureDateChanged = 'Y'
BEGIN
  UPDATE  dbo.stops
     SET  last_updateby = CASE 
                            WHEN i.stp_arrivaldate <> d.stp_arrivaldate OR i.stp_status <> d.stp_status THEN CASE
                                                                                                               WHEN @tmwuser = @TMAgentID THEN @TMAgentReplacement
                                                                                                               ELSE @tmwuser
                                                                                                             END
                            ELSE i.last_updateby
                          END,
          last_updatedate = CASE
                              WHEN i.stp_arrivaldate <> d.stp_arrivaldate OR i.stp_status <> d.stp_status THEN @GETDATE
                              ELSE i.last_updatedate
                            END,
          last_updatebydepart = CASE
                                  WHEN i.stp_departuredate <> d.stp_departuredate OR i.stp_departure_status <> d.stp_departure_status THEN CASE
                                                                                                                                             WHEN @tmwuser = @TMAgentID THEN @TMAgentReplacement
                                                                                                                                             ELSE @tmwuser
                                                                                                                                           END
                                  ELSE i.last_updatebydepart
                                END,
          last_updatedatedepart = CASE
                                    WHEN i.stp_departuredate <> d.stp_departuredate OR i.stp_departure_status <> d.stp_departure_status THEN @GETDATE
                                    ELSE i.last_updatedatedepart
                                  END
    FROM  dbo.stops s  
						INNER JOIN @inserted i ON i.stp_number = s.stp_number
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  i.stp_arrivaldate <> d.stp_arrivaldate
      OR  i.stp_status <> d.stp_status
      OR  i.stp_departuredate <> d.stp_departuredate
      OR  i.stp_departure_status <> d.stp_departure_status
END

IF @LoadFileExport = 'Y' AND (@StpStatusChanged = 'Y' OR @StpArrivalDateChanged = 'Y'  OR @StpReasonLateChanged = 'Y')
  EXECUTE dbo.UtStopsConsolidated_LoadFileExport_sp @inserted, @deleted

IF @ComputeCBPProcessingFlag = 'Y' AND (@CmpIdChanged = 'Y' OR @StpCountryChanged = 'Y')
  EXECUTE dbo.UtStopsConsolidated_ComputeCBPProcessingFlag_sp @inserted, @deleted, @CBPDefaultStrategy

IF @IntermodalMode = '2' AND @inservice <> 'NOCHANGE' AND (@StpStatusChanged = 'Y' OR @StpArrivalDateChanged = 'Y' OR @StpSchdtEarliestChanged = 'Y')
  EXECUTE dbo.UtStopsConsolidated_Intermodal_sp @inserted, @deleted, @InService, @tmwuser, @GETDATE

IF (@SELate = 'Y' AND @StpReasonLateChanged = 'Y') OR (@SELateDepart = 'Y' AND @StpReasonLateDepartChanged = 'Y')
  EXECUTE dbo.UtStopsConsolidated_AutoCreateLateServiceExcpetion_sp @inserted, @deleted, @SELate, @SELateDepart, @SEAsset

-- Begin Purchase Service Logic
IF @PsTrlIdChanged = 'Y'
  EXECUTE dbo.UtStopsConsolidated_PurchaseService_TrailerChange_sp @inserted, @deleted

IF @PsStpEventChanged = 'Y'
  EXECUTE dbo.UtStopsConsolidated_PurchaseService_EventChange_sp @inserted, @deleted, @PurchaseServiceNumbering

IF @PsCmpIdChanged = 'Y'
  UPDATE  PSH
     SET  PSH.psh_vendor_id = i.cmp_id,
          PSH.psh_drop_dt = i.stp_arrivaldate,
          PSH.psh_pickup_dt = DATEADD(HOUR, 6, i.stp_departuredate),
          PSH.psh_promised_dt = DATEADD(HOUR, 6, i.stp_departuredate)
    FROM  dbo.purchaseserviceheader PSH WITH(NOLOCK)
            INNER JOIN @inserted i ON i.psh_number = PSH.psh_number
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  i.cmp_id <> d.cmp_id 
     AND  i.psh_number <> 0;
-- End Purchase Service Logic

IF @MakeCityCmp = 'Y'
  EXECUTE dbo.UtStopsConsolidated_MakeCityCmp_sp @inserted;

IF @CmpIdChanged = 'Y' OR @StpCityChanged = 'Y'
  UPDATE  S
     SET  S.stp_city = c.cmp_city
    FROM  dbo.stops S WITH(NOLOCK)
            INNER JOIN @inserted i ON i.stp_number = S.stp_number
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
            INNER JOIN company c WITH(NOLOCK) ON c.cmp_id = i.cmp_id
   WHERE  (i.cmp_id <> d.cmp_id
      OR   i.stp_city <> d.stp_city)
     AND  i.cmp_id <> 'UNKNOWN'
     AND  i.stp_city <> c.cmp_city;

IF @Auto214Flag = 'Y'
  EXECUTE dbo.UtStopsConsolidated_Auto214Flag_sp @inserted, @deleted, @SlackTime, @EDI214ApptTrigger, @EDINotificationProcessType, @tmwuser, @GETDATE;

IF @ImagingVendorInHouse IN ('TMI', 'FLYINGJ') OR @ImagingVendorOnRoad IN ('TMI', 'FLYINGJ')
  EXECUTE dbo.UtStopsConsolidated_ImagingVendor_sp @inserted, @TripPakStatusTable;

IF @StpReasonLateChanged = 'Y'
  UPDATE  SS
     SET  SS.sch_reasonlatecode = i.stp_reasonlate,
          SS.sch_ontime = CASE
                            WHEN i.stp_reasonlate IS NOT NULL AND i.stp_reasonlate <> 'UNK' AND COALESCE(SS.sch_ontime, 'Y') <> 'N'  THEN 'N'
                            ELSE SS.sch_ontime
                          END
    FROM  dbo.StopSchedules SS WITH(NOLOCK)
            INNER JOIN @inserted i ON i.stp_number = SS.stp_number
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  COALESCE(i.stp_reasonlate, 'NULL') <> COALESCE(d.stp_reasonlate, 'NULL');

IF @OrdHdrNumberChanged = 'Y'
BEGIN
  UPDATE  dbo.referencenumber
     SET  referencenumber.ord_hdrnumber = i.ord_hdrnumber
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  i.ord_hdrnumber <> d.ord_hdrnumber
     AND  ref_table = 'stops'
     AND  ref_tablekey = i.stp_number;

  UPDATE  dbo.referencenumber
     SET  referencenumber.ord_hdrnumber = i.ord_hdrnumber
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
            INNER JOIN dbo.freightdetail fd WITH(NOLOCK) ON fd.stp_number = i.stp_number
   WHERE  i.ord_hdrnumber <> d.ord_hdrnumber
     AND  ref_table = 'freightdetail'
     AND  ref_tablekey = fd.fgt_number;

  UPDATE  S
     SET  S.stp_ord_mileage = 0
    FROM  dbo.stops S
            INNER JOIN @inserted i ON i.stp_number = S.stp_number
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  i.ord_hdrnumber <> d.ord_hdrnumber
     AND  i.ord_hdrnumber = 0
     AND  S.stp_ord_mileage <> 0;
END

IF @StpStatusChanged = 'Y' OR @StpDepartureStatusChanged = 'Y'
  UPDATE  S
     SET  S.stp_detstatus = 0
    FROM  dbo.stops S WITH(NOLOCK)
            INNER JOIN @inserted i ON i.stp_number = S.stp_number
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  (i.stp_status <> d.stp_status
      OR   i.stp_departure_status <> d.stp_departure_status)
     AND   S.stp_detstatus <> 0;

IF @StpStatusChanged = 'Y' OR @StpDepartureStatusChanged = 'Y' OR @StpDetStatusChanged = 'Y'
  WITH SubQuery2 AS
  (
    SELECT  DISTINCT lgh.lgh_number
      FROM  dbo.legheader lgh WITH(NOLOCK)
              INNER JOIN @inserted i ON i.lgh_number = lgh.lgh_number
              INNER JOIN @deleted d ON d.stp_number = i.stp_number
     WHERE  i.stp_status <> d.stp_status
        OR  i.stp_departure_status <> d.stp_departure_status
        OR  COALESCE(i.stp_detstatus, -1) <> COALESCE(d.stp_detstatus, -1)
  ),
  SubQuery AS
  (
    SELECT  stops.lgh_number,
            MAX(COALESCE(stops.stp_detstatus, 0)) MaxDetStatus
      FROM  dbo.stops WITH(NOLOCK)
              INNER JOIN SubQuery2 SQ2 ON SQ2.lgh_number = stops.lgh_number
    GROUP BY stops.lgh_number
  )
  UPDATE  LGH
     SET  LGH.lgh_detstatus = SQ.MaxDetStatus
    FROM  dbo.legheader LGH
            INNER JOIN SubQuery SQ ON SQ.lgh_number = LGH.lgh_number
   WHERE  COALESCE(LGH.lgh_detstatus, -1) <> SQ.MaxDetStatus;

IF @LghNumberChanged = 'Y'
BEGIN
  UPDATE  PW
     SET  PW.lgh_number = i.lgh_number,
          PW.mov_number = i.mov_number,
          PW.last_updatedby = 'ut_stops_consolidated',
          PW.last_updateddatetime = @GETDATE
    FROM  dbo.paperwork PW WITH(NOLOCK)
            INNER JOIN @deleted d ON d.lgh_number = PW.lgh_number
            INNER JOIN @inserted i ON i.stp_number = d.stp_number
            LEFT OUTER JOIN dbo.stops s WITH(NOLOCK) ON s.lgh_number = d.lgh_number
   WHERE  s.stp_number is NULL
     AND  PW.abbr NOT IN (SELECT  abbr
                            FROM  dbo.paperwork WITH(NOLOCK)
                           WHERE  lgh_number = i.lgh_number
                             AND  ord_hdrnumber = i.ord_hdrnumber);
END

IF (@StpStatusChanged = 'Y' OR @StpDepartureStatusChanged = 'Y' OR @StpEventChanged = 'Y' OR
    @CmpIdChanged = 'Y' OR @StpCityChanged = 'Y' OR @StpSchdtEarliestChanged = 'Y' OR
    @StpSchdtLatestChanged = 'Y' OR @StpMfhSequenceChanged = 'Y') AND @StpOptimizationDateChanged = 'N'
BEGIN
  UPDATE  S
     SET  S.stp_optimizationdate = @GETDATE
    FROM  dbo.stops S WITH(NOLOCK)
            INNER JOIN @inserted i ON i.stp_number = S.stp_number
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  (COALESCE(i.stp_status, '') <> COALESCE(d.stp_status, '')
      OR   COALESCE(i.stp_departure_status, '') < COALESCE(d.stp_departure_status, '')
      OR   COALESCE(i.cmp_id, '') <> COALESCE(d.cmp_id, '')
      OR   COALESCE(i.stp_city, 0) <> COALESCE(d.stp_city, 0)
      OR   COALESCE(i.stp_event, '') <> COALESCE(d.stp_event, '')
      OR   COALESCE(i.stp_schdtearliest, CONVERT(DATETIME, 0)) <> COALESCE(d.stp_schdtearliest, CONVERT(DATETIME, 0))
      OR   COALESCE(i.stp_schdtlatest, CONVERT(DATETIME, 0)) <> COALESCE(d.stp_schdtlatest, CONVERT(DATETIME, 0))
      OR   COALESCE(i.stp_mfh_sequence, -1) <> COALESCE(d.stp_mfh_sequence, -1))
     AND  COALESCE(i.stp_optimizationdate, CONVERT(DATETIME, 0)) = COALESCE(D.stp_optimizationdate, CONVERT(DATETIME, 0));

  UPDATE  TP
     SET  TP.trc_optimizationdate = @GETDATE
    FROM  dbo.tractorprofile TP WITH(NOLOCK)
            INNER JOIN dbo.legheader lgh WITH(NOLOCK) ON lgh.lgh_tractor = TP.trc_number
            INNER JOIN @inserted i ON i.lgh_number = lgh.lgh_number
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  (COALESCE(i.stp_status, '') <> COALESCE(d.stp_status, '')
      OR   COALESCE(i.stp_departure_status, '') < COALESCE(d.stp_departure_status, '')
      OR   COALESCE(i.cmp_id, '') <> COALESCE(d.cmp_id, '')
      OR   COALESCE(i.stp_city, 0) <> COALESCE(d.stp_city, 0)
      OR   COALESCE(i.stp_event, '') <> COALESCE(d.stp_event, '')
      OR   COALESCE(i.stp_schdtearliest, CONVERT(DATETIME, 0)) <> COALESCE(d.stp_schdtearliest, CONVERT(DATETIME, 0))
      OR   COALESCE(i.stp_schdtlatest, CONVERT(DATETIME, 0)) <> COALESCE(d.stp_schdtlatest, CONVERT(DATETIME, 0))
      OR   COALESCE(i.stp_mfh_sequence, -1) <> COALESCE(d.stp_mfh_sequence, -1))
     AND  COALESCE(i.stp_optimizationdate, CONVERT(DATETIME, 0)) = COALESCE(D.stp_optimizationdate, CONVERT(DATETIME, 0))
     AND  TP.trc_number <> 'UNKNOWN';
END

IF @HPLRemoved = 'Y'
  DELETE  E
    FROM  dbo.event E
            INNER JOIN @deleted d ON d.stp_number = e.stp_number
            INNER JOIN @inserted i on d.stp_number = i.stp_number
   WHERE  E.evt_eventcode = 'PLD'
     AND  i.stp_event <>'HPL'
     AND  d.stp_event = 'HPL';

IF @DRLRemoved = 'Y'
  DELETE  E
    FROM  dbo.event E
            INNER JOIN @deleted d ON d.stp_number = e.stp_number
            INNER JOIN @inserted i on d.stp_number = i.stp_number
   WHERE  E.evt_eventcode = 'PUL'
     AND  i.stp_event <>'DRL'
     AND  d.stp_event = 'DRL';

IF (@AddSecondaryLoadUnloadEvents IN ('PUP', 'PUPDRP') AND @HPLAdded = 'Y') OR (@AddSecondaryLoadUnloadEvents IN ('DRP', 'PUPDRP') AND @DRLAdded = 'Y')
  EXECUTE dbo.UtStopsConsolidated_AddSecondaryLoadUnloadEvents_sp @inserted, @deleted, @AddSecondaryLoadUnloadEvents

IF @SkipTrigger = 'Y'
BEGIN
  UPDATE  S
     SET  S.skip_trigger = 0
    FROM  dbo.stops S
            INNER JOIN @inserted i ON i.stp_number = S.stp_number
   WHERE  i.skip_trigger = 1;

   RETURN;
END

/*********************************************************************************
 ** UPDATE EVENTS
 *********************************************************************************/
IF EXISTS(SELECT  1
            FROM  dbo.event
                    INNER JOIN inserted i ON event.stp_number = i.stp_number
           WHERE  event.evt_sequence = 1
             AND  (i.stp_event <> event.evt_eventcode
              OR   i.stp_arrivaldate <> event.evt_startdate
              OR   i.stp_departuredate <> event.evt_enddate
              OR   i.stp_schdtearliest <> event.evt_earlydate
              OR   i.stp_schdtlatest <> event.evt_latedate
              OR   i.stp_type <> event.evt_pu_dr
              OR   i.stp_status <> event.evt_status
              OR   i.stp_departure_status <> event.evt_departure_status))
BEGIN
  UPDATE  dbo.event
     SET  evt_eventcode = i.stp_event,
          evt_startdate = i.stp_arrivaldate,
          evt_enddate = i.stp_departuredate,
          evt_earlydate = i.stp_schdtearliest,
          evt_latedate = i.stp_schdtlatest,
          evt_pu_dr = i.stp_type,
          evt_status = i.stp_status,
          evt_departure_status = i.stp_departure_status
    FROM  inserted i
   WHERE  event.stp_number = i.stp_number
     AND  event.evt_sequence = 1
     AND  (i.stp_event <> event.evt_eventcode
      OR   i.stp_arrivaldate <> event.evt_startdate
      OR   i.stp_departuredate <> event.evt_enddate
      OR   i.stp_schdtearliest <> event.evt_earlydate
      OR   i.stp_schdtlatest <> event.evt_latedate
      OR   i.stp_type <> event.evt_pu_dr
      OR   i.stp_status <> event.evt_status
      OR   i.stp_departure_status <> event.evt_departure_status);
END

IF @LghNumberChanged = 'Y'
  UPDATE  E
     SET  evt_driver1 = 'UNKNOWN',
          evt_driver2 = 'UNKNOWN',
          evt_tractor = 'UNKNOWN',
          evt_trailer1 = 'UNKNOWN',
          evt_trailer2 = 'UNKNOWN',
          evt_chassis = 'UNKNOWN',
          evt_dolly = 'UNKNOWN',
          evt_carrier = 'UNKNOWN'
    FROM  dbo.event E
            INNER JOIN @inserted i ON i.stp_number = E.stp_number
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  i.lgh_number <> d.lgh_number;

/*********************************************************************************
 ** UPDATE FREIGHTDETAILS
 *********************************************************************************/
 IF @CmdCodeChanged = 'Y' OR @StpDescriptionChanged = 'Y' OR @StpWeightChanged = 'Y' OR
    @StpWeightunitChanged = 'Y' OR @StpCountChanged = 'Y' OR @StpCountunitChanged = 'Y' OR
    @StpVolumeChanged = 'Y' OR @StpVolumeunitChanged = 'Y' OR @StpPalletsInChanged = 'Y' OR
    @StpPalletsOutChanged = 'Y'
  UPDATE  FD
     SET  FD.cmd_code = i.cmd_code,
          FD.fgt_description = i.stp_description,
          FD.fgt_weight = i.stp_weight,
          FD.fgt_weightunit = i.stp_weightunit,
          FD.fgt_count = i.stp_count,
          FD.fgt_countunit = i.stp_countunit,
          FD.fgt_volume = i.stp_volume,
          FD.fgt_volumeunit = i.stp_volumeunit,
          FD.fgt_pallets_in = i.stp_pallets_in,
          FD.fgt_pallets_out = i.stp_pallets_out
    FROM  dbo.freightdetail FD 
            INNER JOIN @inserted i ON i.stp_number = FD.stp_number AND FD.fgt_sequence = 1
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  (COALESCE(i.cmd_code, '') <> COALESCE(d.cmd_code, '') AND COALESCE(i.cmd_code, '') <> COALESCE(FD.cmd_code, ''))
      OR  (COALESCE(i.stp_description, '') <> COALESCE(d.stp_description, '') AND COALESCE(i.stp_description, '') <> COALESCE(FD.fgt_description, ''))
      OR  (COALESCE(i.stp_weight, 0) <> COALESCE(d.stp_weight, 0) AND COALESCE(i.stp_weight, 0) <> COALESCE(FD.fgt_weight, 0))
      OR  (COALESCE(i.stp_weightunit, '') <> COALESCE(d.stp_weightunit, '') AND COALESCE(i.stp_weightunit, '') <> COALESCE(FD.fgt_weightunit, ''))
      OR  (COALESCE(i.stp_count, 0) <> COALESCE(d.stp_count, 0) AND COALESCE(i.stp_count, 0) <> COALESCE(FD.fgt_count, 0))
      OR  (COALESCE(i.stp_countunit, '') <> COALESCE(d.stp_countunit, '') AND COALESCE(i.stp_countunit, '') <> COALESCE(FD.fgt_countunit, ''))
      OR  (COALESCE(i.stp_volume, 0) <> COALESCE(d.stp_volume, 0) AND COALESCE(i.stp_volume, 0) <> COALESCE(FD.fgt_volume, 0))
      OR  (COALESCE(i.stp_volumeunit, '') <> COALESCE(d.stp_volumeunit, '') AND COALESCE(i.stp_volumeunit, '') <> COALESCE(FD.fgt_volumeunit, ''))
      OR  (COALESCE(i.stp_pallets_in, 0) <> COALESCE(d.stp_pallets_in, 0) AND COALESCE(i.stp_pallets_in, 0) <> COALESCE(FD.fgt_pallets_in, 0))
      OR  (COALESCE(i.stp_pallets_out, 0) <> COALESCE(d.stp_pallets_out, 0) AND COALESCE(i.stp_pallets_out, 0) <> COALESCE(FD.fgt_pallets_out, 0));

/*********************************************************************************
 ** UPDATE REFERENCE NUMBERS
 *********************************************************************************/
IF @StpRefNumChanged = 'Y' OR @StpRefTypeChanged = 'Y'
BEGIN
  -- Insert new reference number when none existed
  INSERT INTO dbo.referencenumber
    (
      ref_tablekey,
      ref_type,
      ref_number,
      ref_sequence,
      ref_table,
      ord_hdrnumber
    )
    SELECT  i.stp_number,
            i.stp_reftype,
            i.stp_refnum,
            1,
            'stops',
            i.ord_hdrnumber
      FROM  @inserted i
              INNER JOIN @deleted d ON d.stp_number = i.stp_number
              LEFT OUTER JOIN referencenumber WITH(NOLOCK) ON referencenumber.ref_tablekey = i.stp_number AND referencenumber.ref_table = 'stops' AND referencenumber.ref_sequence = 1
     WHERE  (COALESCE(i.stp_refnum, '') <> COALESCE(d.stp_refnum, '') OR COALESCE(i.stp_reftype, '') <> COALESCE(d.stp_reftype, ''))
       AND  referencenumber.ref_id IS NULL
       AND  COALESCE(i.stp_refnum, '') <> '';

  -- Update existing reference number when change
  UPDATE  RN
     SET  RN.ref_type = i.stp_reftype,
          RN.ref_number = i.stp_refnum,
          RN.ord_hdrnumber = i.ord_hdrnumber
    FROM  dbo.referencenumber RN
            INNER JOIN @inserted i ON i.stp_number = RN.ref_tablekey AND RN.ref_table = 'stops' AND RN.ref_sequence = 1
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  (COALESCE(i.stp_refnum, '') <> COALESCE(d.stp_refnum, '')
      OR   COALESCE(i.stp_reftype, '') <> COALESCE(d.stp_reftype, ''))
     AND  COALESCE(i.stp_refnum, '')  <> '';

  -- Delete existing reference number when refence number removed, resequence if needed
  DELETE  RN 
  OUTPUT  deleted.ref_tablekey INTO @StopsList
    FROM  dbo.referencenumber RN
            INNER JOIN @inserted i ON i.stp_number = RN.ref_tablekey AND RN.ref_table = 'stops' AND RN.ref_sequence = 1
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  COALESCE(i.stp_refnum, '') = '' 
     AND  COALESCE(d.stp_refnum, '') <> '';
         
  IF @@ROWCOUNT > 0
  BEGIN
    DECLARE StopsCursor CURSOR LOCAL FAST_FORWARD FOR
      SELECT stp_number FROM @StopsList;
    
    OPEN StopsCursor;
    FETCH StopsCursor INTO @stp_number;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.denormalize_refnumbers 'stops', @stp_number;
    
      FETCH StopsCursor INTO @stp_number;
    END

    CLOSE StopsCursor;
    DEALLOCATE StopsCursor;
  END
END

/*********************************************************************************
 ** UPDATE LOCATION INFORMATION
 *********************************************************************************/
IF @StpCityChanged = 'Y' OR @CmpIdChanged = 'Y'
  UPDATE  S
     SET  S.stp_state = c.cty_state
    FROM  dbo.stops S
            INNER JOIN @inserted i ON i.stp_number = S.stp_number
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
            INNER JOIN dbo.city c WITH(NOLOCK) ON c.cty_code = S.stp_city
   WHERE  (COALESCE(i.cmp_id, '') <> COALESCE(d.cmp_id, '')
      OR   COALESCE(i.stp_city, 0) <> COALESCE(d.stp_city,0))
     AND  i.stp_state <> c.cty_state;

/*********************************************************************************
 ** GEOCODE REQUEST TO TOTALMAIL
 *********************************************************************************/
IF @TMGeocodingFormId > 0
BEGIN
  DECLARE StopsCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT  i.cmp_id,
          i.stp_number
    FROM  @inserted i
            INNER JOIN dbo.company WITH(NOLOCK) ON company.cmp_id = i.cmp_id
   WHERE  (COALESCE(company.cmp_latseconds, 0) = 0 
     AND   COALESCE(company.cmp_longseconds, 0) = 0
     AND   COALESCE(company.cmp_latlongverifications, 0) <> -1)
      OR   COALESCE(company.cmp_latlongverifications, 0) = 0;
     
    
  OPEN StopsCursor;
  FETCH StopsCursor INTO @cmp_id, @stp_number;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @execcommand = 'EXEC tmail_IssueGeoCodeRequest2 ' + CONVERT(VARCHAR(15), @TMGeocodingFormId) + ', ''' + REPLACE(@TMGeocodingDeliverTo, '''', '''''') + ''', ''' + REPLACE(@cmp_id, '''', '''''') + ''', ''' + CAST(@stp_number AS VARCHAR(100)) + '''';
    EXECUTE sp_executeSQL @execcommand;
    
    FETCH StopsCursor INTO @cmp_id, @stp_number;
  END

  CLOSE StopsCursor;
  DEALLOCATE StopsCursor;
END
GO
ALTER TABLE [dbo].[stops] ADD CONSTRAINT [pk_stp_number] PRIMARY KEY CLUSTERED ([stp_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cmparrival] ON [dbo].[stops] ([cmp_id], [stp_arrivaldate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_leghdrnum] ON [dbo].[stops] ([lgh_number], [ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lghnum] ON [dbo].[stops] ([lgh_number], [ord_hdrnumber]) INCLUDE ([stp_lgh_mileage]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_leghdrnum_stp_ico_stp_number] ON [dbo].[stops] ([lgh_number], [stp_ico_stp_number_child]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lghnum_stpmfhseq_depstat] ON [dbo].[stops] ([lgh_number], [stp_mfh_sequence], [stp_departure_status]) INCLUDE ([ord_hdrnumber], [stp_city], [stp_state], [stp_arrivaldate], [stp_departuredate], [mov_number], [stp_event], [stp_status], [cmp_id], [stp_lgh_mileage]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mov] ON [dbo].[stops] ([mov_number], [stp_sequence], [cmp_id], [stp_city]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_stp_ordnum] ON [dbo].[stops] ([ord_hdrnumber]) INCLUDE ([stp_arrivaldate], [stp_departuredate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_stp_arrvdt] ON [dbo].[stops] ([stp_arrivaldate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_stp_city] ON [dbo].[stops] ([stp_city]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_stops_HLT] ON [dbo].[stops] ([stp_event], [mov_number], [stp_mfh_sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_stops_stp_ico_stp_number_child] ON [dbo].[stops] ([stp_ico_stp_number_child]) INCLUDE ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_stops_ico_stp_number_child_lgh_number] ON [dbo].[stops] ([stp_ico_stp_number_child], [lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_stops_stp_lgh_mileage] ON [dbo].[stops] ([stp_lgh_mileage]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_stops_stp_refnum] ON [dbo].[stops] ([stp_reftype], [stp_refnum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_stops_sch_seq] ON [dbo].[stops] ([stp_schdtearliest], [stp_sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_stops_status_lghnum] ON [dbo].[stops] ([stp_status], [lgh_number], [mov_number], [stp_mfh_sequence], [stp_schdtearliest]) INCLUDE ([stp_city]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_stpdetstatus] ON [dbo].[stops] ([stp_status], [stp_departure_status], [stp_arrivaldate], [ord_hdrnumber], [stp_number], [lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_stops_stp_transfer_stp] ON [dbo].[stops] ([stp_transfer_stp]) INCLUDE ([mfh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_stp_type] ON [dbo].[stops] ([stp_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_stops_timestamp] ON [dbo].[stops] ([timestamp]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[stops] ADD CONSTRAINT [FK_cmpid] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[stops] TO [public]
GO
GRANT INSERT ON  [dbo].[stops] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stops] TO [public]
GO
GRANT SELECT ON  [dbo].[stops] TO [public]
GO
GRANT UPDATE ON  [dbo].[stops] TO [public]
GO

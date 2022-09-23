SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_create_empty_move_stop]
	@lghnum int,		
	@movnum int,
	@cmpid char(25),    --PTS 61189 change cmp_id fields to 25 length
	@stpseq int,
	@evtcode varchar(6),  
	@arvdate datetime,	
	@stpnum int out
AS

declare @cmp_name varchar(100), 
	@cmp_address1 varchar(100), 
	@cmp_address2 varchar(100), 
	@cmp_city int, 
	@cmp_zip varchar(10), 
	@cmp_primaryphone varchar(20), 
	@cmp_secondaryphone varchar(20),
	@cmp_state varchar(6), 
	@cmp_region1 varchar(6), 
	@cmp_region2 varchar(6), 
	@cmp_region3 varchar(6), 
	@cmp_region4 varchar(6), 
	@cmp_contact varchar(30),
	@earlydate datetime,
	@latedate datetime,
	@evtnum int,
	@fgtnum int

set @earlydate = '1950-01-01'
set @latedate = '2049-12-31'

select @cmp_name = cmp_name, @cmp_address1 = cmp_address1, @cmp_address2 = cmp_address2, @cmp_city = cmp_city, @cmp_zip = cmp_zip, @cmp_primaryphone = cmp_primaryphone, @cmp_secondaryphone = cmp_secondaryphone, @cmp_state = cmp_state, @cmp_region1 = cmp_region1, @cmp_region2 = cmp_region2, @cmp_region3 = cmp_region3, @cmp_region4 = cmp_region4, @cmp_contact = cmp_contact
 from company where cmp_id = @cmpid

EXEC @stpnum = dbo.getsystemnumber 'STPNUM', '' 
EXEC @evtnum = dbo.getsystemnumber 'EVTNUM', ''
EXEC @fgtnum = dbo.getsystemnumber 'FGTNUM', ''

INSERT INTO freightdetail 
	( stp_number, fgt_sequence, fgt_number, 		--1	
	cmd_code, fgt_description, fgt_reftype, 		--2
	fgt_refnum,fgt_pallets_in, 				--3
	fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1, --4	
	fgt_carryins2, skip_trigger, fgt_quantity,		--5
	fgt_weight, fgt_weightunit, fgt_count,			--6
	fgt_countunit, fgt_volume, fgt_volumeunit,		--7
	tare_weightunit, tare_weight, fgt_stackable,		--8 
	fgt_ratingunit, fgt_charge_type, fgt_rate_type, 	--9
	fgt_ordered_loadingmeters, fgt_pallet_type, fgt_loadingmeters, --10
	fgt_specific_flashpoint, cpr_density )			--11
VALUES ( @stpnum, 1, @fgtnum, 					--1
	'UNKNOWN', 'UNKNOWN', '',				--2
	null, 0,						--3
	0, 0, 0,						--4
	0, 1, null,						--5
	null, 'LBS', null,					--6
	'PCS', null, 'CUB',					--7 
	'LBS', 0, 'N',						--8
	0, 0, 0,						--9
	0, 'UNK', 0,						--10
	0, 1)						--11

INSERT INTO event 
	( evt_driver1, evt_driver2, evt_tractor, 		--1
	evt_trailer1, evt_trailer2, ord_hdrnumber, 		--2
	stp_number, evt_startdate, evt_earlydate, 		--3
	evt_latedate, evt_enddate, evt_reason, 			--4
	evt_carrier, evt_sequence, fgt_number, 			--5
	evt_number, evt_pu_dr, evt_eventcode, 			--6
	evt_status , skip_trigger) 				--7
VALUES ('UNKNOWN', 'UNKNOWN', 'UNKNOWN', 			--1
	'UNKNOWN', 'UNKNOWN', 0, 				--2
	@stpnum, @arvdate, @earlydate, 				--3	
	@latedate, @arvdate, 'UNK', 				--4
	'UNKNOWN', 1, null, 					--5
	@evtnum, 'NONE', @evtcode, 				--6
	'OPN' , 1)						--7

INSERT INTO stops (
	ord_hdrnumber,   --1
  	stp_number,   
	cmp_id,   
        stp_region1,   
        stp_region2,   	--5
        stp_region3,   
        stp_city,   
        stp_state,   
        stp_schdtearliest,   
        stp_origschdt,   	--10
        stp_arrivaldate,   
        stp_departuredate,   
        stp_reasonlate,   
        stp_schdtlatest,   
        lgh_number,   	--15
        mfh_number,   
        stp_type,   
        stp_paylegpt,   
        shp_hdrnumber,   
        stp_sequence,   	--20
        stp_region4,   
        stp_lgh_sequence,   
        trl_id,   
        stp_mfh_sequence,   
        stp_event,		--25   
        stp_mfh_position,   
        stp_lgh_position,   
        stp_mfh_status,   
        stp_lgh_status,   
        stp_ord_mileage,   	--30
        stp_lgh_mileage,   
        stp_mfh_mileage,   
        mov_number,   
        stp_loadstatus,   
        stp_weight,   		--35
        stp_weightunit,   
        cmd_code,   
        stp_description,   
        stp_count,   
        stp_countunit,   	--40
        cmp_name,   
        stp_comment,   
        stp_status,   
        stp_reftype,   
        stp_refnum,		--45
	stp_address,
 	stp_address2,
	stp_zipcode,
	stp_phonenumber,
	stp_phonenumber2,	--50
        stp_contact,
	stp_volumeunit,
	stp_departure_status )		  
  VALUES ( 0,		--1  
	@stpnum,  
	@cmpid,   
	@cmp_region1,   
	@cmp_region2,  	--5
	@cmp_region3,   
	@cmp_city, 
	@cmp_state,   
	@earlydate,
	@arvdate,	--10
	@arvdate,
	@arvdate,
	'UNK',   
	@latedate,
	@lghnum,		--15
	0,   
	'UNK',   
	'Y',   -- got error trying to begin the empty move in dispatch when this was null.
	null,   
	0,   		--20			
	@cmp_region4,
	null,   
	'UNKNOWN',   
	@stpseq,   
	@evtcode,   	--25
	null,   
	null,   
	null,   
	'AVL',   
	0,   		--30
	0,   
	0,   
	@movnum,
	null,   
	null,   	--35
	'LBS',   
	'UNKNOWN',   
	'UNKNOWN',   
	0,              
	'PCS',  	--40 
	@cmp_name,
	null,   
	'OPN',   
	'',   
	null,		--45
	@cmp_address1,
	@cmp_address2,
	@cmp_zip,
	@cmp_primaryphone,
	@cmp_secondaryphone,  --50
	@cmp_contact,
	'CUB',
	'OPN' ) 

GO
GRANT EXECUTE ON  [dbo].[tmail_create_empty_move_stop] TO [public]
GO

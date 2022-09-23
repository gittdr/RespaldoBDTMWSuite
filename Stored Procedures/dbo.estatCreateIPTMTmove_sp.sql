SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--- this proc is not actually used 11/3/06
Create procedure [dbo].[estatCreateIPTMTmove_sp] 
	@company varchar(8),  	-- to location
 	@user varchar(128) 	-- estat user login
as	
SET NOCOUNT ON

-- 10/2/06: 31347 new estat proc - client specific 
-- This proc is used by the estat SHRET (Request Empty Trailers) to ccreate
-- an empty move representing the request for an empty trailer. 
-- The first stop on the move is the company id 'MTRQST', a special company 
-- created to be the shipper on empty trailer reqeusts.   
-- It creates two entries in stops (htm,dmt) and a legheader entry, then 
-- invokes update_move (which creates entries in the event table).
-----e.g. estatCreateIPTMTmove_sp 'abel2', 'abel' 

DECLARE @movenum as INT 
declare @stopnum1 as INT
declare @stopnum2 as INT
declare @lghnum as INT
declare @eventnum as INT  --??needed? not yet used
EXEC @movenum =  dbo.getsystemnumber 'MOVNUM', NULL
EXEC @stopnum1 = dbo.getsystemnumber 'STPNUM', NULL
EXEC @stopnum2 = dbo.getsystemnumber 'STPNUM', NULL
EXEC @lghnum   = dbo.getsystemnumber 'LEGHDR', NULL
EXEC @eventnum = dbo.getsystemnumber 'EVTNUM',NULL --??needed?

declare @startdate datetime
declare @enddate datetime
select @startdate = dateadd(mi,+5,getdate())  
select @enddate = dateadd(mi,+10,getdate())  
declare @startcity as int
declare @stopcity as int 
select @startcity = isnull(cmp_city,0) from company where cmp_id = 'MTRQST' 
select @stopcity = isnull(cmp_city,0) from company where cmp_id = @company 
INSERT INTO stops 
	( trl_id, ord_hdrnumber, stp_number, 			--1
	stp_city, stp_arrivaldate, stp_schdtearliest, 		--2
	stp_schdtlatest, cmp_id, cmp_name, 			--3
	stp_departuredate, stp_reasonlate, lgh_number, 		--4
	stp_reasonlate_depart, stp_sequence, stp_mfh_sequence, 	--5	
	cmd_code, stp_description, stp_type, 			--6
	stp_event, stp_status, mfh_number, 			--7
	mov_number, stp_origschdt, stp_paylegpt, 		--8
	stp_region1, stp_region2, stp_region3, 			--9
	stp_region4, stp_state, stp_lgh_status, 		--10
	stp_reftype, stp_refnum,stp_loadstatus, 		--11
	stp_phonenumber, stp_delayhours, stp_zipcode, 		--12
	stp_ooa_stop, stp_address, 				--13
	 skip_trigger,						--14
	stp_weight, stp_weightunit, stp_count,                  --15 
	stp_countunit, stp_volume, stp_volumeunit, 		--16
        stp_ord_mileage, stp_lgh_mileage ,stp_lgh_sequence,     --17
	stp_comment,stp_screenmode                              --18
	)
VALUES 	( 'UNK', 0, @stopnum1, 			--1
	@startcity, @startdate, @startdate,	--2 
--
	@startdate, 'MTRQST', NULL,		--3 
	@startdate, 'UNK', @lghnum, 		--4
	'UNK', 0, 1, 				--5
	NULL, NULL, NULL, 			--6
	'HMT', 'OPN', 0, 			--7 
	@movenum, @startdate, 'Y', 		--8
	'UNK', 'UNK', 'UNK', 			--9 
	'UNK', 'UNK', 'AVL', 			--10 
	NULL,NULL, 'LD', 			--11
	NULL, 0.0, NULL,			--12 
	0, '',  				--13
	0, 					--14
	NULL, NULL, NULL,			--15
	NULL, NULL, NULL,			--16  
        NULL,NULL,NULL,        			--17
	NULL, NULL                   		--18
	)

INSERT INTO stops 
	( trl_id, ord_hdrnumber, stp_number, 			--1
	stp_city, stp_arrivaldate, stp_schdtearliest, 		--2
	stp_schdtlatest, cmp_id, cmp_name, 			--3
	stp_departuredate, stp_reasonlate, lgh_number, 		--4
	stp_reasonlate_depart, stp_sequence, stp_mfh_sequence, 	--5	
	cmd_code, stp_description, stp_type, 			--6
	stp_event, stp_status, mfh_number, 			--7
	mov_number, stp_origschdt, stp_paylegpt, 		--8
	stp_region1, stp_region2, stp_region3, 			--9
	stp_region4, stp_state, stp_lgh_status, 		--10
	stp_reftype, stp_refnum,stp_loadstatus, 		--11
	stp_phonenumber, stp_delayhours, stp_zipcode, 		--12
	stp_ooa_stop, stp_address, 				--13
	 skip_trigger,						--14
	stp_weight, stp_weightunit, stp_count,                  --15 
	stp_countunit, stp_volume, stp_volumeunit, 		--16
        stp_ord_mileage, stp_lgh_mileage ,stp_lgh_sequence,     --17
	stp_comment,stp_screenmode                              --18
	)
VALUES 	( 'UNK', 0, @stopnum2, 		--1
	@stopcity, @enddate, @enddate,		--2 
	@enddate, @company, NULL,		--3 
	@enddate, 'UNK', @lghnum, 		--4
	'UNK', 0, 2, 			--5
	NULL, NULL, NULL, 			--6
	'DMT', 'OPN', 0, 			--7 
	@movenum, @enddate, 'Y', 		--8
	'UNK', 'UNK', 'UNK', 	--9 
	'UNK', 'UNK', 'AVL', 		--10 
	NULL,NULL, 'MT', 			--11
	NULL, 0.0, NULL,			--12 
	0, '',  				--13
	0, 					--14
	NULL, NULL, NULL,			--15
	NULL, NULL, NULL,			--16  
        NULL,NULL,NULL,        			--17
	NULL, NULL                   		--18
	)

INSERT INTO legheader 
	( lgh_number, 				--1
	lgh_startdate,  lgh_enddate,  		--2	
	lgh_outstatus,				--3
	stp_number_start, stp_number_end, 	--4
	cmp_id_start, cmp_id_end,		--5
        mov_number,				--6
	lgh_schdtearliest, lgh_schdtlatest,     --7
	ord_hdrnumber,				--8
	lgh_fueltaxstatus, lgh_type1,		--9
	lgh_active, lgh_enddate_arrival,	--10 
	lgh_split_flag, lgh_createdby,		--11  
	lgh_createdon, lgh_createapp, 		--12  
	lgh_updatedby, 				--13
	lgh_updatedon, lgh_updateapp,		--14 
	lgh_tm_status				--15
	)
VALUES 	( @lghnum, 				--1
	  @startdate, @enddate,			--2
	  'AVL',				--3
          @stopnum1, @stopnum2,			--4
	  'RQSTMT',  @company,			--5	
          @movenum,				--6	
	  '1950-01-01', '2049-12-31',		--7
	  0,					--8	
	  'NPD', 'MTTRL',			--9   ??
          'Y', @enddate,			--10
          'N', @user,				--11 
	  getdate(), 'ESTAT',			--12
	  @user,				--13
	  getdate(), 'ESTAT',			--14
	  'NOSENT'				--15	
	)
exec update_move @movenum
--select @movenum movenumber
GO
GRANT EXECUTE ON  [dbo].[estatCreateIPTMTmove_sp] TO [public]
GO

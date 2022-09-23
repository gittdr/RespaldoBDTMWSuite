SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[estatCLSRpt_sp]
-- to do: replace the ubo sql here with that in estatOSRpt.
-- Does not return data on orders that are not in the legheader or whose status is: MST
-- exec estatCLSRpt_sp '1/1/2007', '12/31/2009', 'xxxxxx', '', 'o', 'ANY', 'Y'
-- exec estatCLSRpt_sp '1/1/2007', '12/31/2009', 'xxxxxx', '', 'm', 'ANY', 'Y'

-- 9/10/08: Option return billable events only
--          support companytype = O and ANY
-- pts 37750: cross dock support 
-- pts29391: support consolidated loads ie dont't let user view stops on 
--           orders other than the orders user is permitted to view 
	(
	@begdate		datetime,
	@enddate		datetime,
	@login 			varchar(132),		-- 40655
	@orderstatus	varchar(254),
	@sortby		  	varchar(1),			-- 'o' for order number, 'm' for move number
	@companytype	varchar(6),			-- 'B' for billto, 'S' for shipper, 'C' for consignee, 'O' for order by, 
										--  'BSCO' for billto, shipper, consignee or orderby, 'ANY' for no restriction 
	@bo				varchar(10)			-- 'Y' for billable events only
	)
AS
SET NOCOUNT ON

if (@orderstatus='ALL' or @orderstatus='' or @orderstatus=NULL ) 
	begin
		Select @orderstatus =''
	end

create table #temp2 (usercompid varchar(8) not null)  
Insert into #temp2
select cmp_id from estatusercompanies where login = @login 
/**** STOP DETAIL ****/

create table #StopDetail (
	LegNumber	int	NULL,
	Tractor		varchar(8)	NULL,
	LegStatus	varchar(6),
	Trailer		varchar(13),
	StpStatus	varchar(40),
	OrderHdrNumber	int	NULL,
	OrderNumber     varchar (12),
	OrdStatus	varchar(40),
	RefNumber	varchar(30),  -- 29308  -- order header ref number
	RefType     varchar(6),    
	cmp_name	varchar(100) NULL,	-- 29298
	City		varchar(24),		-- 39046
	St		varchar(6),	
	StpEvent	char (40),
	Scheduled	datetime,
	Actual		datetime,
	Driver		varchar(8),
	MoveNumber	int	NULL,
	StpSeq		int	NULL,
	StpMfhNum	int	NULL,   -- 37750
	Billable	char(1) NULL
)

/**** STOP DETAIL ****/
--If orders should be limited to bill-to 
IF (@companytype = 'B')
BEGIN
	insert into #StopDetail
	SELECT 	legheader.lgh_number, 
	legheader.lgh_tractor, 
	legheader.lgh_outstatus, 
	legheader.lgh_primary_trailer, 
	stops.stp_status, 
	orderheader.ord_hdrnumber, 
	orderheader.ord_number, 
	orderheader.ord_status, 
	orderheader.ord_refnum, 
	orderheader.ord_reftype, 
	company.cmp_name,
	city.cty_name, 
	city.cty_state, 
	stops.stp_event, 
	stops.stp_schdtlatest, 
	stops.stp_arrivaldate, 
	legheader.lgh_driver1, 
	legheader.mov_number, 
	stops.stp_mfh_sequence,
	stops.mfh_number,  --37750
	eventcodetable.ect_billable as billable
	FROM 	orderheader, stops, legheader, city, company, eventcodetable
	--WHERE 	orderheader.mov_number = legheader.mov_number   --37750
	WHERE 	stops.mov_number = legheader.mov_number  --37750
             AND legheader.lgh_number = stops.lgh_number
	AND stops.stp_city = city.cty_code
	AND stops.cmp_id = company.cmp_id
	and eventcodetable.abbr = stops.stp_event
	and orderheader.ord_billto in (select usercompid from #temp2 )
	AND (orderheader.ord_dest_latestdate BETWEEN @begdate AND @enddate)
       	AND (orderheader.ord_status = @orderstatus or @orderstatus = '')
	AND orderheader.ord_status <> 'MST'
        -- 29391
        -- These two lines assure that only stops on THIS order (and nonbillable stops)
        -- are picked up, as opposed to every stop on the move to which this order is
        -- attached. I.e. if you remove these two lines then: if this order has been
        -- consolidated with others, then the report will show all the stops on this
        -- this order's move, including stops that are not on this order.    
        and (stops.ord_hdrnumber = orderheader.ord_hdrnumber)  -- 29391  
	END
	ELSE
	BEGIN
		--If orders should be limited to shipper 
		IF (@companytype = 'S')
		BEGIN
			insert into #StopDetail
			SELECT 	legheader.lgh_number, 
			legheader.lgh_tractor, 
			legheader.lgh_outstatus, 
			legheader.lgh_primary_trailer, 
			stops.stp_status, 
			orderheader.ord_hdrnumber, 
			orderheader.ord_number, 
			orderheader.ord_status, 
			orderheader.ord_refnum, 
			orderheader.ord_reftype, 
			company.cmp_name,
			city.cty_name, 
			city.cty_state, 
			stops.stp_event, 
			stops.stp_schdtlatest, 
			stops.stp_arrivaldate, 
			legheader.lgh_driver1, 
			legheader.mov_number, 
			stops.stp_mfh_sequence,
			stops.mfh_number,  --37750
			eventcodetable.ect_billable as billable
			FROM 	orderheader, stops, legheader, city, company, eventcodetable
			--WHERE 	orderheader.mov_number = legheader.mov_number   --37750
			WHERE 	stops.mov_number = legheader.mov_number  --37750
							  AND legheader.lgh_number = stops.lgh_number
			AND stops.stp_city = city.cty_code
			AND stops.cmp_id = company.cmp_id
			and eventcodetable.abbr = stops.stp_event
			and orderheader.ord_shipper in (select usercompid from #temp2 )
			AND (orderheader.ord_dest_latestdate BETWEEN @begdate AND @enddate)
	       		AND (orderheader.ord_status = @orderstatus or @orderstatus = '')
			AND orderheader.ord_status <> 'MST'
			-- 29391
			-- This line assures that only stops on THIS order (and nonbillable stops)
			-- are picked up, as opposed to every stop on the move to which this order is
			-- attached. I.e. if you remove these two lines then: if this order has been
			-- consolidated with others, then the report will show all the stops on this
			-- this order's move, including stops that are not on this order. 
			and (stops.ord_hdrnumber = orderheader.ord_hdrnumber) -- 29391 37750
		END
		ELSE
		BEGIN
			--If orders should be limited to consignee 
			IF (@companytype = 'C')
			BEGIN
				insert into #StopDetail
				SELECT 	legheader.lgh_number, 
				legheader.lgh_tractor, 
				legheader.lgh_outstatus, 
				legheader.lgh_primary_trailer, 
				stops.stp_status, 
				orderheader.ord_hdrnumber, 
				orderheader.ord_number, 
				orderheader.ord_status, 
				orderheader.ord_refnum, 
				orderheader.ord_reftype, 
				company.cmp_name,
				city.cty_name, 
				city.cty_state, 
				stops.stp_event, 
				stops.stp_schdtlatest, 
				stops.stp_arrivaldate, 
				legheader.lgh_driver1, 
				legheader.mov_number, 
				stops.stp_mfh_sequence,
				stops.mfh_number,  --37750
				eventcodetable.ect_billable as billable
				FROM 	orderheader, stops, legheader, city, company, eventcodetable
				--WHERE 	orderheader.mov_number = legheader.mov_number   --37750
				WHERE 	stops.mov_number = legheader.mov_number  --37750
                                      		AND legheader.lgh_number = stops.lgh_number
				AND stops.stp_city = city.cty_code
				AND stops.cmp_id = company.cmp_id
				and eventcodetable.abbr = stops.stp_event
				and orderheader.ord_consignee in (select usercompid from #temp2 )
				AND (orderheader.ord_dest_latestdate BETWEEN @begdate AND @enddate)
		       		AND (orderheader.ord_status = @orderstatus or @orderstatus = '')
				AND orderheader.ord_status <> 'MST'
				and (stops.ord_hdrnumber = orderheader.ord_hdrnumber)  -- 29391 37750
 			END
			ELSE
			BEGIN
				IF (@companytype = 'O')  -- order-by
				BEGIN
					insert into #StopDetail
					SELECT 	legheader.lgh_number, 
					legheader.lgh_tractor, 
					legheader.lgh_outstatus, 
					legheader.lgh_primary_trailer, 
					stops.stp_status, 
					orderheader.ord_hdrnumber, 
					orderheader.ord_number, 
					orderheader.ord_status, 
					orderheader.ord_refnum, 
					orderheader.ord_reftype, 
					company.cmp_name,
					city.cty_name, 
					city.cty_state, 
					stops.stp_event, 
					stops.stp_schdtlatest, 
					stops.stp_arrivaldate, 
					legheader.lgh_driver1, 
					legheader.mov_number, 
					stops.stp_mfh_sequence,
					stops.mfh_number,  --37750
					eventcodetable.ect_billable as billable
					FROM 	orderheader, stops, legheader, city, company, eventcodetable
					--WHERE 	orderheader.mov_number = legheader.mov_number   --37750
					WHERE 	stops.mov_number = legheader.mov_number  --37750
                                      			AND legheader.lgh_number = stops.lgh_number
					AND stops.stp_city = city.cty_code
					AND stops.cmp_id = company.cmp_id
					and eventcodetable.abbr = stops.stp_event
					and orderheader.ord_company in (select usercompid from #temp2 )
					AND (orderheader.ord_dest_latestdate BETWEEN @begdate AND @enddate)
		       			AND (orderheader.ord_status = @orderstatus or @orderstatus = '')
					AND orderheader.ord_status <> 'MST'
					and (stops.ord_hdrnumber = orderheader.ord_hdrnumber)  -- 29391 37750
				 END
				ELSE -- no restrictions ie user company can be shipper, consignee, orderby or billto 
				BEGIN
					IF (@companytype = 'BSCO')  
					BEGIN
						insert into #StopDetail
						SELECT 	legheader.lgh_number, 
						legheader.lgh_tractor, 
						legheader.lgh_outstatus, 
						legheader.lgh_primary_trailer, 
						stops.stp_status, 
						orderheader.ord_hdrnumber, 
						orderheader.ord_number, 
						orderheader.ord_status, 
						orderheader.ord_refnum, 
						orderheader.ord_reftype, 
						company.cmp_name,
						city.cty_name, 
						city.cty_state, 
						stops.stp_event, 
						stops.stp_schdtlatest, 
						stops.stp_arrivaldate, 
						legheader.lgh_driver1, 
						legheader.mov_number, 
						stops.stp_mfh_sequence,
						stops.mfh_number,  --37750
						eventcodetable.ect_billable as billable
						FROM 	orderheader, stops, legheader, city, company, eventcodetable
						--WHERE 	orderheader.mov_number = legheader.mov_number   --37750
						WHERE 	stops.mov_number = legheader.mov_number  --37750
												  AND legheader.lgh_number = stops.lgh_number
						AND stops.stp_city = city.cty_code
						AND stops.cmp_id = company.cmp_id
						and eventcodetable.abbr = stops.stp_event
						and
						(orderheader.ord_shipper in (select usercompid from #temp2) 
							or
						 orderheader.ord_company in (select usercompid from #temp2) 
							or
						 orderheader.ord_consignee in (select usercompid from #temp2) 
							or
						 orderheader.ord_billto in (select usercompid from #temp2) 
						)			
						AND (orderheader.ord_dest_latestdate BETWEEN @begdate AND @enddate)
							AND (orderheader.ord_status = @orderstatus or @orderstatus = '')
							AND orderheader.ord_status <> 'MST'							   
									and (stops.ord_hdrnumber = orderheader.ord_hdrnumber)  -- 29391 37750
					END
					ELSE -- No restriction
						BEGIN
							insert into #StopDetail
							SELECT 	legheader.lgh_number, 
							legheader.lgh_tractor, 
							legheader.lgh_outstatus, 
							legheader.lgh_primary_trailer, 
							stops.stp_status, 
							orderheader.ord_hdrnumber, 
							orderheader.ord_number, 
							orderheader.ord_status, 
							orderheader.ord_refnum, 
							orderheader.ord_reftype, 
							company.cmp_name,
							city.cty_name, 
							city.cty_state, 
							stops.stp_event, 
							stops.stp_schdtlatest, 
							stops.stp_arrivaldate, 
							legheader.lgh_driver1, 
							legheader.mov_number, 
							stops.stp_mfh_sequence,
							stops.mfh_number,  --37750
							eventcodetable.ect_billable as billable
							FROM 	orderheader, stops, legheader, city, company, eventcodetable
							--WHERE 	orderheader.mov_number = legheader.mov_number   --37750
							WHERE 	stops.mov_number = legheader.mov_number  --37750
                                      					AND legheader.lgh_number = stops.lgh_number
							AND stops.stp_city = city.cty_code
							AND stops.cmp_id = company.cmp_id
							and eventcodetable.abbr = stops.stp_event
							AND (orderheader.ord_dest_latestdate BETWEEN @begdate AND @enddate)
		       					AND (orderheader.ord_status = @orderstatus or @orderstatus = '')
							AND orderheader.ord_status <> 'MST'
							and (stops.ord_hdrnumber = orderheader.ord_hdrnumber)  -- 29391 37750
						END
					
				END
			END
		END
	END

If @bo = 'Y'  delete #StopDetail where billable <> 'Y'

update #StopDetail set  stpstatus = 'Open' where stpstatus = 'OPN'
update #StopDetail set  stpstatus = 'Done' where stpstatus = 'DNE'

update #StopDetail set ordstatus =  name from labelfile	where labeldefinition = 'DispStatus' 	and ordstatus = abbr
update #StopDetail set stpevent = name from labelfile where labeldefinition = 'CheckCallEvent' and stpevent = abbr

IF (@sortby = 'o')
	BEGIN
		SELECT 	
		    MoveNumber [Move],		
			OrderNumber [Order],
			OrderHdrNumber [Ord_hdrnumber],
			OrdStatus   [Status],
			RefNumber  + ' (' + RefType + ')'  [Ref Number],   
			StpEvent	[Event],
			StpStatus	[Event Status],
			Scheduled	[Scheduled Arrival],		
			Actual		[Actual Arrival],
			Cmp_name + ' ' + City + ', ' + St [Location],
          	Tractor,		
			Trailer,			
			--Driver,
			--MoveNumber,
			--StpSeq,
			OrderHdrNumber [Ord_hdrnumber]
			FROM 	#StopDetail 
			ORDER BY OrderNumber, stpmfhnum, StpSeq  -- 37750
	END
ELSE
	BEGIN
		SELECT 	
	   		convert(Varchar(10),MoveNumber)  [Move],
			
			OrderNumber [Order],  
			OrderHdrNumber [Ord_hdrnumber],
			OrdStatus   [Status],
			RefNumber  + ' (' + RefType + ')'  [Ref Number],   
			StpEvent	[Event],
			StpStatus	[Event Status],
			Scheduled	[Scheduled Arrival],		
			Actual		[Actual Arrival],
			Cmp_name + ' ' + City + ', ' + St [Location],
           	Tractor,		
			Trailer,			
			--Driver,
			--MoveNumber,
			--StpSeq,
		OrderHdrNumber [Ord_hdrnumber]
		FROM 	#StopDetail 
		ORDER BY MoveNumber, stpmfhnum,StpSeq  -- 37750
	END		
drop table #StopDetail
GO
GRANT EXECUTE ON  [dbo].[estatCLSRpt_sp] TO [public]
GO

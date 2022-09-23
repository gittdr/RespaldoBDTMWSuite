SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_tripassets_sp](@ord_hdrnumber	INT,
				 @p_mov_number INT = 0)
AS

/*
 * 
 * NAME: d_tripassets_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provides paperwork window with legheader data.
 *
 * RETURNS:
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber, int, input, 0;
 *       order number sent from paperwork window.
 * 002 - @p_mov_number, int, input, null;
 *       mov number sent from paperwork window.
 *
 * REFERENCES:
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * PTS 18035 - DJM - Limit by the Legs that are actually associated with the Order,
 *	not all the Legs that are associated with the Leg's Movement.
 * 03/1/2005.01 - PTSnnnnn - AuthorName -Revision Description 
 * 11/28/2006.01 PTS 33716 - PRB - Created this section.
 * 11/29/2006.02 PTS 34565 - PRB - Added mov number parameter to do lookups.
 * 02/07/2007.01 PTS 36129 - EMK - Added blank record retrieval for cancelled orders
 * 
 *
 **/

IF (@p_mov_number <> 0)
BEGIN
	SELECT legheader.lgh_startdate,   
		legheader.lgh_enddate,   
		legheader.lgh_endcity,   
		legheader.lgh_driver1,   
		legheader.lgh_driver2,   
		legheader.lgh_tractor,   
		legheader.lgh_primary_trailer,   
		legheader.lgh_primary_pup,   
		legheader.mov_number,   
		legheader.lgh_startcity,
		city_a.cty_nmstct startcitynmstct,
		city_b.cty_nmstct endcitynmstct,
		mpp1.mpp_lastfirst,
		mpp2.mpp_lastfirst,
		lgh_number,
		'Y' requirements_met,   --Dummy column
		--PTS 40877 JJF 20080207
		fgt_event_pup_present = (select top 1 stp_type
					from stops stp 
					where stp.lgh_number = legheader.lgh_number 
						and stp_type = 'PUP'),
		fgt_event_drp_present = (select top 1 stp_type
					from stops stp 
					where stp.lgh_number = legheader.lgh_number 
						and stp_type = 'DRP')
		--END PTS 40877 JJF 20080207

	FROM legheader
		LEFT OUTER JOIN city city_a ON legheader.lgh_startcity = city_a.cty_code
		LEFT OUTER JOIN city city_b ON legheader.lgh_endcity = city_b.cty_code
		LEFT OUTER JOIN manpowerprofile mpp1 ON legheader.lgh_driver1 = mpp1.mpp_id
		LEFT OUTER JOIN manpowerprofile mpp2 ON legheader.lgh_driver2 = mpp2.mpp_id
	WHERE legheader.lgh_number IN (SELECT DISTINCT lgh_number 
					FROM stops 
					WHERE mov_number = @p_mov_number)
	ORDER BY lgh_number ASC

/* PRB PTS34565 - OLD ANSI Joins
	FROM legheader,   
		city city_a,   
		city city_b,
		manpowerprofile mpp1,
		manpowerprofile mpp2	  
	WHERE ( legheader.lgh_number in (Select Distinct lgh_number from stops where mov_number = @p_mov_number) ) 
		AND ( legheader.lgh_startcity *= city_a.cty_code )
		AND ( legheader.lgh_endcity *= city_b.cty_code )
		AND ( legheader.lgh_driver1 *= mpp1.mpp_id)
		AND ( legheader.lgh_driver2 *= mpp2.mpp_id) 
	ORDER BY lgh_number asc
*/
END
ELSE
	BEGIN
		-- PTS 36129 EMK 
		--Check for cancelled trip
		--03/21/07 Changed TOP 1 to DISTINCT in select.  Need all legs 
		IF (SELECT ord_status FROM orderheader where ord_hdrnumber = @ord_hdrnumber) = 'ICO'	
			SELECT DISTINCT
				(select ord_origin_earliestdate from orderheader where ord_hdrnumber = @ord_hdrnumber) lgh_startdate,
				(select ord_dest_earliestdate from orderheader where ord_hdrnumber = @ord_hdrnumber) lgh_enddate,
				lgh_endcity  = 0,   
				lgh_driver1  = 'UNKNOWN',   
				lgh_driver2 = '',   
				lgh_tractor = '',   
				lgh_primary_trailer = '',   
				lgh_primary_pup = '',   
				mov_number = 0,   
				lgh_startcity = 0,
				startcitynmstct = 'Cancelled/',
				endcitynmstct = '',
				mpp_lastfirst = '',
				mpp_lastfirst1 = '',
				lgh_number,
				'Y' requirements_met,   --Dummy column
				--PTS 40877 JJF 20080207
				fgt_event_pup_present = (select top 1 stp_type
							from stops stp 
							where stp.lgh_number = stops.lgh_number 
								and stp_type = 'PUP'),
				fgt_event_drp_present = (select top 1 stp_type
							from stops stp 
							where stp.lgh_number = stops.lgh_number 
								and stp_type = 'DRP')
				--END PTS 40877 JJF 20080207

			FROM stops
			WHERE stops.ord_hdrnumber = @ord_hdrnumber
		ELSE
			SELECT legheader.lgh_startdate,   
				legheader.lgh_enddate,   
				legheader.lgh_endcity,   
				legheader.lgh_driver1,   
				legheader.lgh_driver2,   
				legheader.lgh_tractor,   
				legheader.lgh_primary_trailer,   
				legheader.lgh_primary_pup,   
				legheader.mov_number,   
				legheader.lgh_startcity,
				city_a.cty_nmstct startcitynmstct,
				city_b.cty_nmstct endcitynmstct,
				mpp1.mpp_lastfirst,
				mpp2.mpp_lastfirst,
				lgh_number,
				'Y' requirements_met,   --Dummy column
				--PTS 40877 JJF 20080207
				fgt_event_pup_present = (select top 1 stp_type
							from stops stp 
							where stp.lgh_number = legheader.lgh_number 
								and stp_type = 'PUP'),
				fgt_event_drp_present = (select top 1 stp_type
							from stops stp 
							where stp.lgh_number = legheader.lgh_number 
								and stp_type = 'DRP')
				--END PTS 40877 JJF 20080207
			FROM legheader
				LEFT OUTER JOIN city city_a ON legheader.lgh_startcity = city_a.cty_code
				LEFT OUTER JOIN city city_b ON legheader.lgh_endcity = city_b.cty_code
				LEFT OUTER JOIN manpowerprofile mpp1 ON legheader.lgh_driver1 = mpp1.mpp_id
				LEFT OUTER JOIN manpowerprofile mpp2 ON legheader.lgh_driver2 = mpp2.mpp_id
			WHERE legheader.lgh_number IN (SELECT DISTINCT lgh_number 
						FROM stops 
						WHERE ord_hdrnumber = @ord_hdrnumber)
			ORDER BY lgh_number ASC
	
	/* PRB PTS34565 - OLD ANSI Joins
		FROM legheader,   
			city city_a,   
			city city_b,
			manpowerprofile mpp1,
			manpowerprofile mpp2	  
		WHERE ( legheader.lgh_number in (select distinct lgh_number from stops where ord_hdrnumber = @ord_hdrnumber)) 
			AND ( legheader.lgh_startcity *= city_a.cty_code )
			AND ( legheader.lgh_endcity *= city_b.cty_code )
			AND ( legheader.lgh_driver1 *= mpp1.mpp_id)
			AND ( legheader.lgh_driver2 *= mpp2.mpp_id) 
		ORDER BY lgh_number asc
	*/
	END


GO
GRANT EXECUTE ON  [dbo].[d_tripassets_sp] TO [public]
GO

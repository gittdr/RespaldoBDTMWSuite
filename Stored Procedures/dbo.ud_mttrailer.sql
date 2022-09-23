SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.ud_mttrailer    Script Date: 6/1/99 11:55:09 AM ******/
CREATE PROCEDURE [dbo].[ud_mttrailer] (@trl char(13), 
										@mov int)
 AS
/* EXEC timerins  "ud_mttrailer", "START" */

Declare 	@minstat 	smallint,
			@maxstat 	smallint,
			@maxseq 		int,
			@avldate 	datetime,
			@avlcmp 		char(8),
			@avlcity 	int,
			@avlstat 	char(6)

SELECT @maxseq = MAX ( stp_mfh_sequence )
FROM event, stops
WHERE stops.stp_number = event.stp_number AND
		stops.mov_number = @mov AND
		evt_trailer1 = @trl

SELECT @minstat = MIN ( code ), 
		@maxstat = MAX ( code )
FROM event, stops, labelfile
where evt_status = abbr and
		stops.stp_number = event.stp_number and
		labeldefinition = 'StopStatus' and
		stops.mov_number = @mov and 
		evt_trailer1 = @trl

SELECT @avldate = stp_arrivaldate,
		@avlcmp = cmp_id,
		@avlcity = stp_city
	FROM stops
	WHERE mov_number = @mov AND
			stp_mfh_sequence = @maxseq
		
IF @minstat = 30 
	SELECT @avlstat = 'AVL'
ELSE IF @maxstat = 10
	SELECT @avlstat = 'AVL'
ELSE
	SELECT @avlstat = 'USE'
			
	UPDATE trailerprofile 
	SET trl_status = @avlstat,
		trl_avail_date = @avldate,
		trl_avail_cmp_id = @avlcmp,
		trl_avail_city = @avlcity
	FROM labelfile
	WHERE trl_id = @trl AND
		labelfile.labeldefinition = 'TrlStatus' AND
		( ( labelfile.abbr = trl_status AND labelfile.code < 200 ) OR 
			trl_status = 'UNK' )

/* EXEC timerins "ud_mttrailer", "END" */
return




GO
GRANT EXECUTE ON  [dbo].[ud_mttrailer] TO [public]
GO

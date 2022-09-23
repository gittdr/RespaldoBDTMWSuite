SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.get_legheaders_sp    Script Date: 6/1/99 11:55:02 AM ******/
create proc [dbo].[get_legheaders_sp](	@stringparm varchar(13),
				@numberparm int,
				@retrieve_by varchar(6))
as
declare @mov_number int,
	@curleghdr int
			
SELECT @mov_number = -1

/* LOOK UP BY ORDER NUMBER */
IF (@retrieve_by = "ORDNUM")	 	
	SELECT @mov_number = mov_number 
		FROM orderheader
		WHERE ord_number = @stringparm     

/* LOOK UP BY ORDERHEADER NUMBER */
IF (@retrieve_by = "ORDHDR")
	SELECT @mov_number = mov_number 
		FROM orderheader
		WHERE ord_hdrnumber = @numberparm

/* LOOK UP BY LGH NUMBER */
IF (@retrieve_by = "LGHNUM")
	BEGIN
	SELECT @curleghdr = @numberparm
	SELECT @mov_number = mov_number  
		FROM legheader
		WHERE lgh_number = @numberparm
	END

/* LOOK UP BY MOVE NUMBER */
IF (@retrieve_by = "MOVE")
	BEGIN
	 SELECT @mov_number = @numberparm  
	END

/* LOOK UP BY DRIVER, TRACTOR, TRAILER, CARRIER */
IF (@retrieve_by = "DRV" or @retrieve_by = "TRC" 
 or @retrieve_by = "TRL" or @retrieve_by = "CAR")

	execute @mov_number = cur_activity  @retrieve_by, @stringparm, @curleghdr OUT

SELECT lgh_number, @mov_number, @curleghdr from legheader where mov_number = @mov_number


GO
GRANT EXECUTE ON  [dbo].[get_legheaders_sp] TO [public]
GO

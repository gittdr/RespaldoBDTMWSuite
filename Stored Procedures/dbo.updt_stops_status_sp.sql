SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.updt_stops_status_sp    Script Date: 6/1/99 11:55:10 AM ******/
Create Procedure [dbo].[updt_stops_status_sp] @lghnum int
As
Begin
   While ( Select Count(*)
             From stops
            Where stops.lgh_number = @lghnum AND
                  stops.stp_status <> "DNE" ) > 0

   Begin
      SET ROWCOUNT 1

      Update stops
         Set stops.stp_status = "DNE"
       Where stops.lgh_number = @lghnum AND
             stops.stp_status <> "DNE"
   End
End
SET ROWCOUNT 0
Return


GO
GRANT EXECUTE ON  [dbo].[updt_stops_status_sp] TO [public]
GO

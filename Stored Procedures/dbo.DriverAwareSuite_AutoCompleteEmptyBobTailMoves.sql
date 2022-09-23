SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE      Procedure [dbo].[DriverAwareSuite_AutoCompleteEmptyBobTailMoves] 
As

Declare @MoveNumber int
Declare @StopNumber int

Select lgh_enddate,legheader_active.lgh_number,legheader_active.mov_number,stp_number,lgh_split_flag
into   #TempBobTailMoves
From   legheader_active (NOLOCK),
       stops (NOLOCK)
Where  cmp_id_start = cmp_id_end 
       and
       legheader_active.ord_hdrnumber=0 
       and 
       ord_stopcount < 2 
       and
       lgh_split_flag = 'N'
       and
       legheader_active.lgh_number = stops.lgh_number
       And
       lgh_enddate <= GetDate()
       And
       lgh_outstatus <> 'CMP'



Set @MoveNumber = (Select min(mov_number) from #TempBobTailMoves)

While @MoveNumber Is Not Null
Begin

	Set @StopNumber = (select min(stp_number) from #TempBobTailMoves where mov_number = @MoveNumber)
			
	While @StopNumber Is Not Null
	Begin
		update stops Set stp_status ='DNE'
		Where stp_number = @StopNumber

		Set @StopNumber = (select min(stp_number) from #TempBobTailMoves where mov_number = @MoveNumber and stp_number > @StopNumber)

	End

	exec update_assetassignment @MoveNumber

	exec update_move_light @MoveNumber

	Set @MoveNumber = (Select min(mov_number) from #TempBobTailMoves where mov_number > @MoveNumber)

End


GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_AutoCompleteEmptyBobTailMoves] TO [public]
GO

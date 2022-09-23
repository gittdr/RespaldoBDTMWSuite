SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE Function [dbo].[fnc_TMWRN_OrderNotes](@OrderHeaderNumber int)
Returns varchar(1000)
As
Begin

Declare @Notes varchar(1000)
Declare @ID int

Set @ID = (Select min(not_number) from notes WITH (NOLOCK) where notes.nre_tablekey = @OrderHeaderNumber and ntb_table = 'orderheader')

While @ID Is Not Null
Begin

Set @Notes = @Notes + IsNull((select IsNull(not_text,'') + '/' from notes WITH (NOLOCK) where not_number = @ID),'')


Set @Id = (Select min(not_number) from notes WITH (NOLOCK) where notes.nre_tablekey = @OrderHeaderNumber and notes.not_number > @ID and ntb_table = 'orderheader')

End

Return @Notes

End


GO

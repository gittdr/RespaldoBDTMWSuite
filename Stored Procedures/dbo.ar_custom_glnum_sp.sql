SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.ar_custom_glnum_sp    Script Date: 6/1/99 11:54:06 AM ******/
create procedure [dbo].[ar_custom_glnum_sp] @tts_co varchar(10),
	@colval1 varchar(20),
	@colval2 varchar(20),
	@colval3 varchar(20),
	@colval4 varchar(20),
	@colval5 varchar(20),
	@colval6 varchar(20),
	@colval7 varchar(20),
	@colval8 varchar(20),
	@colval9 varchar(20),
	@colval10 varchar(20)

as

Declare @gl_rows integer
	
Select sequence_id,
	gl_key1,
	gl_key2,
	gl_key3,
	gl_key4,
	gl_key5,
	gl_key6,
	gl_key7,
	gl_key8,
	gl_key9,
	gl_key10,
	seg1,
	seg2,
	seg3,
	seg4
into #temp_glnum
from intglnum
where tts_co = @tts_co and
	(@colval1 like gl_key1 or
	 	gl_key1 is null) and
	(@colval2 like gl_key2 or
	 	gl_key2 is null) and
	(@colval3 like gl_key3 or
	 	gl_key3 is null) and
	(@colval4 like gl_key4 or
	 	gl_key4 is null) and
	(@colval5 like gl_key5 or
	 	gl_key5 is null) and
	(@colval6 like gl_key6 or
	 	gl_key6 is null) and
	(@colval7 like gl_key7 or
	 	gl_key7 is null) and
	(@colval8 like gl_key8 or
	 	gl_key8 is null) and
	(@colval9 like gl_key9 or
	 	gl_key9 is null) and
	(@colval10 like gl_key10 or
	 	gl_key10 is null)
Order By sequence_id
	
Select @gl_rows = count(*)
From #temp_glnum

if @gl_rows > 0
	Select seg1, seg2, seg3, seg4 from #temp_glnum
	Where sequence_id = (select max(sequence_id) from #temp_glnum)



GO
GRANT EXECUTE ON  [dbo].[ar_custom_glnum_sp] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROCEDURE  [dbo].[tripfolderreport_addon]  @cmpid varchar(8) ,@cmdcode varchar(8)
AS
/*
Created by DPETE 2/7/3 for PTS 17049 to consolidate three subreports into one
// 06/18/2009 MDH PTS 47612: Re-wrote to use table variables, fix bug
// 10/02/2009 vjh pts 49345 remove line of debug code at end



*/
DECLARE @notes table
	(
	cmp_directions text null,
	cmp_note varchar(255),
	notekey varchar (30),
	cmd_note varchar(800) null,
	cmd_name varchar(20),
	seq tinyint,
	seq2 tinyint)

Select @cmdcode = IsNull(@cmdcode,'[')

--create table #notes (cmp_directions text null,
--cmp_note varchar(255),notekey varchar (30),cmd_note varchar(800) null,cmd_name varchar(20),seq tinyint,
--seq2 tinyint)

Insert into @notes
select cmp_directions,'',cmp_id,'','',1,1 from company		/* 06/18/2009 MDH PTS 47612: Changed 3rd column from cmp_directions to cmp_id */
Where cmp_id = @cmpid
and datalength(IsNull(cmp_directions,'')) > 0

Insert Into @notes
Select '',not_text,nre_tablekey,'','',2,not_sequence
From Notes Where ntb_table = 'company'
and not_type = 'D'
and nre_tablekey = @cmpid
and(ISNULL(not_expires, getdate()) >= 
CASE ISNULL((SELECT gi_string1 FROM generalinfo WHERE gi_name = 'showexpirednotes'), 'Y')
WHEN 'N' THEN getdate()
ELSE ISNULL(not_expires, getdate()) 
END)


Insert Into @notes
Select '','','',not_text,nre_tablekey,3,not_sequence
From Notes Where ntb_table = 'commodity'
and nre_tablekey = @cmdcode
and(ISNULL(not_expires, getdate()) >= 
CASE ISNULL((SELECT gi_string1 FROM generalinfo WHERE gi_name = 'showexpirednotes'), 'Y')
WHEN 'N' THEN getdate()
ELSE ISNULL(not_expires, getdate()) 
END)

If (Select count(*) From @notes) = 0
  Insert into @notes Select '','','','','',1,1

select * from @notes
order by seq,seq2

--drop table #notes
GO
GRANT EXECUTE ON  [dbo].[tripfolderreport_addon] TO [public]
GO

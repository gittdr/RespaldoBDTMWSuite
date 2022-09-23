CREATE TABLE [dbo].[tborequest]
(
[tbo_id] [int] NOT NULL IDENTITY(1, 1),
[tbo_trlid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tbo_jobcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tbo_jobnum] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tbo_duedate] [datetime] NOT NULL,
[tbo_earliestdate] [datetime] NULL,
[tbo_assigndate] [datetime] NULL,
[tbo_latestdate] [datetime] NULL,
[tbo_notes] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tbo_completed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_tbo_completed] DEFAULT ('N'),
[tbo_createdate] [datetime] NULL,
[tbo_createdby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tbo_lastupdatedate] [datetime] NULL,
[tbo_lastupdatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tbo_sent] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_tborequest] ON [dbo].[tborequest]
FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
  begin

/**
 * 
 * NAME:
 * notes.it_tbo_request
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * This Insert trigger will set the creation audit columns to the user and time that the request was entered
 * It will also create a note to the trailer that the request was made for containing the notes from the request as the note text
 *
 * RETURNS:
 * [N/A]
 *
 * RESULT SETS: 
 * [None]
 *
 * PARAMETERS:
 * NONE
 *
 * REFERENCES: NONE
 * 
 * REVISION HISTORY:
 * 07/24/2005 ? PTS33640 - Jason Bauwin ? Original
 *
 **/

     declare @v_tmwuser varchar (255), @v_counter int, @v_systemcontrol int, @v_trlid varchar(13)

	select	@v_trlid = min(tbo_trlid)
	  from	inserted

	while isnull(@v_trlid, 'XX**XX') <> 'XX**XX'
	begin
		exec tbo_trl_type2_update @v_trlid

		select	@v_trlid = min(tbo_trlid)
		  from	inserted
		 where	tbo_trlid > @v_trlid
	end

     exec gettmwuser @v_tmwuser output

     update tborequest
        set tbo_createdate = getdate(),
            tbo_earliestdate = getdate(),
            tbo_latestdate = inserted.tbo_duedate,
            tbo_createdby = @v_tmwuser
       from inserted
      where inserted.tbo_id = tborequest.tbo_id

    --create a note on the trailer profile with the notes from the tbo request
    select @v_counter = min (inserted.tbo_id)
      from inserted
    while @v_counter is not null
    begin
       EXECUTE @v_systemcontrol = getsystemnumber 'NOTES', ''
       insert into notes (not_number, not_text, not_urgent, not_expires, ntb_table, nre_tablekey, not_sequence, not_text_large)
         select @v_systemcontrol,
                tbo_notes,
                'N', 
                '12/31/49 23:59:00.000', 
                'trailerprofile', 
                i.tbo_trlid,
                (select max(not_sequence) + 1
                   from notes
                  where ntb_table = 'trailerprofile'
                    and nre_tablekey =i.tbo_trlid),
                tbo_notes
           from inserted i
    select @v_counter = min (inserted.tbo_id)
      from inserted
     where tbo_id > @v_counter
    end
  end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_tborequest] ON [dbo].[tborequest]
FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
  begin
/**
 * 
 * NAME:
 * notes.ut_tbo_request
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * This Update trigger will set the modification audit columns to the user and time that the request was entered.
 *
 * RETURNS:
 * [N/A]
 *
 * RESULT SETS: 
 * [None]
 *
 * PARAMETERS:
 * NONE
 *
 * REFERENCES: NONE
 * 
 * REVISION HISTORY:
 * 07/24/2005 ? PTS33640 - Jason Bauwin ? Original
 *
 **/
     declare @v_tmwuser varchar (255), @v_trlid varchar(13)

	select	@v_trlid = min(tbo_trlid)
	  from	inserted

	while isnull(@v_trlid, 'XX**XX') <> 'XX**XX'
	begin
		exec tbo_trl_type2_update @v_trlid

		select	@v_trlid = min(tbo_trlid)
		  from	inserted
		 where	tbo_trlid > @v_trlid
	end

     exec gettmwuser @v_tmwuser output
     update tborequest
        set tbo_lastupdatedate = getdate(),
            tbo_lastupdatedby = @v_tmwuser
       from inserted
      where inserted.tbo_id = tborequest.tbo_id
  end
GO
ALTER TABLE [dbo].[tborequest] ADD CONSTRAINT [pk_tborequest] PRIMARY KEY CLUSTERED ([tbo_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tbo_trlid] ON [dbo].[tborequest] ([tbo_trlid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tborequest] TO [public]
GO
GRANT INSERT ON  [dbo].[tborequest] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tborequest] TO [public]
GO
GRANT SELECT ON  [dbo].[tborequest] TO [public]
GO
GRANT UPDATE ON  [dbo].[tborequest] TO [public]
GO

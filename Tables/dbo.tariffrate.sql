CREATE TABLE [dbo].[tariffrate]
(
[timestamp] [timestamp] NULL,
[tar_number] [int] NULL,
[trc_number_row] [int] NOT NULL,
[trc_number_col] [int] NOT NULL,
[tra_rate] [money] NULL,
[tra_apply] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tra_retired] [datetime] NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL,
[tra_activedate] [datetime] NULL,
[tra_rateasflat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_tra_rateasflat] DEFAULT ('N'),
[tra_minrate] [money] NULL,
[tra_minqty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_tra_minqty] DEFAULT ('N'),
[tra_billmiles] [money] NULL,
[tra_paymiles] [money] NULL,
[tra_standardhours] [money] NULL,
[tra_mincharge] [money] NULL,
[tra_remarks1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tra_remarks2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tra_remarks3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tra_remarks4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_tariffrate_changelog]
ON [dbo].[tariffrate]
FOR INSERT, UPDATE 
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

declare @updatecount	int,
	@delcount	int, 
	@runtrigger int

/* 06/24/2013 MDH PTS 62023: Add check for trigger_control  */
Select @runtrigger = count(*) from trigger_control with (nolock) where application_name = APP_NAME() and 
		trigger_name = 'iut_tariffrate_changelog' and fire_or_not = 0
If @runtrigger > 0
	return

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted

if (@updatecount > 0 and not update(last_updateby) and not update(last_updatedate)) OR
	(@updatecount > 0 and @delcount = 0)
	Update TariffRate
	set last_updateby = @tmwuser,
		last_updatedate = getdate()
	from inserted
	where inserted.trc_number_row = TariffRate.trc_number_row
		and inserted.trc_number_col = TariffRate.trc_number_col
		and (isnull(TariffRate.last_updateby,'') <> @tmwuser
		OR isNull(TariffRate.last_updatedate,'19500101') <> getdate())
	
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--ILB PTS#18486 10/21/03
CREATE TRIGGER [dbo].[ut_tariffrate_fingerprinting] ON [dbo].[tariffrate]
FOR UPDATE
AS
SET NOCOUNT ON; -- 06/25/2007 MDH PTS: 38085: Added 

/*
    11/17/2014  Mindy Curnutt			PTS 84589 - If an update fired but no rows were changed, get out of the trigger.
    03/23/2017  Eric Blinn        PTS xxxxx - Removing updates of expedite_audit and doing only one multi-row insert
*/

IF NOT EXISTS(SELECT 1 FROM inserted)
BEGIN
  RETURN;
END;

/* 06/24/2013 MDH PTS 62023: Add check for trigger_control  */
IF EXISTS(SELECT 
            1 
          FROM 
            trigger_control WITH (nolock) 
          WHERE 
            application_name = APP_NAME()
              AND
            trigger_name = 'ut_tariffrate_fingerprinting'
              AND 
            fire_or_not = 0)
BEGIN
  RETURN;
END;

DECLARE @ls_user VARCHAR(20);
EXEC gettmwuser @ls_user OUTPUT;

--PTS33529 QA-FIX RECODE 1/23/2009 <<START>>
IF EXISTS(SELECT 1 FROM dbo.generalinfo WHERE gi_name = 'Tar_Show_Cell_History' AND gi_string1 = 'Y')
     AND
   UPDATE(tra_rate)
BEGIN
  UPDATE 
    dbo.tariffratehistory
  SET 
    tra_rate = inserted.tra_rate
  FROM 
    inserted
  WHERE 
    inserted.tar_number = tariffratehistory.tar_number
      AND
    inserted.trc_number_row = tariffratehistory.trc_number_row
      AND
    inserted.trc_number_col = tariffratehistory.trc_number_col
      AND 
    GETDATE() BETWEEN tariffratehistory.trh_fromdate AND tariffratehistory.trh_todate;
END;
--PTS33529 QA-FIX RECODE 1/23/2009 <<END>>

--Don't insert audit row unless the feature is turned on..
IF EXISTS(SELECT 1 FROM dbo.generalinfo WHERE gi_name = 'FingerprintAudit' AND LEFT(gi_string1, 1) = 'Y')
BEGIN

  --Insert where the row doesn't already exist..
  INSERT INTO expedite_audit(
    ord_hdrnumber
  , updated_by
  , activity
  , updated_dt
  , update_note
  , key_value
  , mov_number
  , lgh_number
  , join_to_table_name
  , tar_number)
  SELECT 
    ord_hdrnumber
  , updated_by
  , activity
  , updated_dt
  , LEFT(RIGHT(update_note, LEN(update_note) - 2), 255) --They all start with ", " so no matter what is first needs those 2 characters stripped.
  , key_value
  , mov_number
  , lgh_number
  , join_to_table_name
  , tar_number
  FROM (
          SELECT 
            0 ord_hdrnumber
          , @ls_user updated_by
          , 'Tariff Rate Update' activity
          , GETDATE() updated_dt
          , CASE 
              WHEN COALESCE(i.tra_rate , -5107) <> COALESCE(d.tra_rate , -5107) THEN
                    ', Tariff Rate '+COALESCE(CAST(d.tra_rate AS VARCHAR(20)) , 'null')+' -> '+COALESCE(CAST(i.tra_rate AS VARCHAR(20)) , 'null')+' -- For ROW: '+
                    CASE tr.trc_matchvalue WHEN 'UNKNOWN' THEN CAST(tr.trc_rangevalue AS VARCHAR) ELSE COALESCE(tr.trc_matchvalue , '?') END+' For COLUMN: '+
                    CASE tc.trc_matchvalue WHEN 'UNKNOWN' THEN CAST(tc.trc_rangevalue AS VARCHAR) ELSE COALESCE(tc.trc_matchvalue , '?') END 
              ELSE ''
            END +
            CASE 
              WHEN i.trc_number_row <> d.trc_number_row THEN ', Tariff Number Row'+COALESCE(CAST(d.trc_number_row AS VARCHAR(20)) , 'null')+' -> '+COALESCE(CAST(i.trc_number_row AS VARCHAR(20)) , 'null')
              ELSE ''
            END + 
            CASE 
              WHEN i.trc_number_col <> d.trc_number_col THEN ', Tariff Number Col'+COALESCE(CAST(d.trc_number_col AS VARCHAR(20)) , 'null')+' -> '+COALESCE(CAST(i.trc_number_col AS VARCHAR(20)) , 'null')
              ELSE ''
            END + 
            CASE 
              WHEN COALESCE(i.tra_apply , 'nU1L') <> COALESCE(d.tra_apply , 'nU1L') THEN ', Tariff Apply '+LTRIM(RTRIM(COALESCE(d.tra_apply , 'null')))+' -> '+LTRIM(RTRIM(COALESCE(i.tra_apply , 'null')))
              ELSE ''
            END +
            CASE  
              WHEN COALESCE(i.tra_retired , '1901-03-30') <> COALESCE(d.tra_retired , '1901-03-30') THEN ', Retired Date '+COALESCE(CONVERT( VARCHAR(30) , d.tra_retired , 101)+' '+CONVERT(VARCHAR(30) , d.tra_retired , 108) , 'null')+' -> '+COALESCE(CONVERT(VARCHAR(30) , i.tra_retired , 101)+' '+CONVERT(VARCHAR(30) , i.tra_retired , 108) , 'null')
              ELSE ''
            END +
            CASE 
              WHEN COALESCE(i.tra_activedate , '1901-03-30') <> COALESCE(d.tra_activedate , '1901-03-30') THEN ', Active Date '+COALESCE(CONVERT( VARCHAR(30) , d.tra_activedate , 101)+' '+CONVERT(VARCHAR(30) , d.tra_activedate , 108) , 'null')+' -> '+COALESCE(CONVERT(VARCHAR(30) , i.tra_activedate , 101)+' '+CONVERT(VARCHAR(30) , i.tra_activedate , 108) , 'null')
              ELSE ''
            END update_note
          , CAST(i.tar_number AS VARCHAR(20)) key_value
          , 0 mov_number
          , 0 lgh_number
          , 'tariffrate' join_to_table_name
          , i.tar_number tar_number
          FROM 
            deleted d
              INNER JOIN
            inserted i ON i.tar_number = d.tar_number
              LEFT OUTER JOIN
            tariffrowcolumn tr ON i.trc_number_row = tr.trc_number
              LEFT OUTER JOIN
            tariffrowcolumn tc ON i.trc_number_col = tc.trc_number) SubQuery
    WHERE
      --if none of the cases catch then the note will be '' and we needn't record anything.
      update_note <> '';
END;
GO
ALTER TABLE [dbo].[tariffrate] ADD CONSTRAINT [PK_tariffrate] PRIMARY KEY CLUSTERED ([trc_number_row], [trc_number_col]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tar_number] ON [dbo].[tariffrate] ([tar_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffrate] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffrate] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffrate] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffrate] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffrate] TO [public]
GO

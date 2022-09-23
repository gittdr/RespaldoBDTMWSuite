CREATE TABLE [dbo].[ttrdetail]
(
[ttrd_number] [int] NOT NULL,
[ttr_number] [int] NOT NULL,
[ttrd_terminusnbr] [smallint] NOT NULL,
[ttrd_level] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ttrd_include_or_exclude] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ttrd_sequence] [smallint] NOT NULL,
[ttrd_value] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ttrd_intvalue] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [k_ttrtermlvl] ON [dbo].[ttrdetail] ([ttr_number], [ttrd_terminusnbr], [ttrd_level]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_ttrdnumber] ON [dbo].[ttrdetail] ([ttrd_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttrdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[ttrdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttrdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[ttrdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttrdetail] TO [public]
GO

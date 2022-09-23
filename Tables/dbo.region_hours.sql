CREATE TABLE [dbo].[region_hours]
(
[region_id] [int] NOT NULL,
[sunday] [tinyint] NOT NULL CONSTRAINT [DF_regionhours_sunday] DEFAULT (0),
[sunday_open_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_sunday_open_shipping1] DEFAULT ('0000'),
[sunday_close_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_sunday_close_shipping1] DEFAULT ('0000'),
[sunday_open_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_sunday_open_receiving1] DEFAULT ('0000'),
[sunday_close_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_sunday_close_receiving1] DEFAULT ('0000'),
[sunday_open_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_sunday_open_shipping2] DEFAULT ('0000'),
[sunday_close_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_sunday_close_shipping2] DEFAULT ('0000'),
[sunday_open_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_sunday_open_receiving2] DEFAULT ('0000'),
[sunday_close_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_sunday_close_receiving2] DEFAULT ('0000'),
[monday] [tinyint] NOT NULL CONSTRAINT [DF_regionhours_monday] DEFAULT (1),
[monday_open_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_monday_open_shipping1] DEFAULT ('0800'),
[monday_close_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_monday_close_shipping1] DEFAULT ('1200'),
[monday_open_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_monday_open_receiving1] DEFAULT ('0800'),
[monday_close_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_monday_close_receiving1] DEFAULT ('1200'),
[monday_open_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_monday_open_shipping2] DEFAULT ('1300'),
[monday_close_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_monday_close_shipping2] DEFAULT ('1700'),
[monday_open_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_monday_open_receiving2] DEFAULT ('1300'),
[monday_close_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_monday_close_receiving2] DEFAULT ('1700'),
[tuesday] [tinyint] NOT NULL CONSTRAINT [DF_regionhours_tuesday] DEFAULT (1),
[tuesday_open_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_tuesday_open_shipping1] DEFAULT ('0800'),
[tuesday_close_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_tuesday_close_shipping1] DEFAULT ('1200'),
[tuesday_open_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_tuesday_open_receiving1] DEFAULT ('0800'),
[tuesday_close_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_tuesday_close_receiving1] DEFAULT ('1200'),
[tuesday_open_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_tuesday_open_shipping2] DEFAULT ('1300'),
[tuesday_close_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_tuesday_close_shipping2] DEFAULT ('1700'),
[tuesday_open_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_tuesday_open_receiving2] DEFAULT ('1300'),
[tuesday_close_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_tuesday_close_receiving2] DEFAULT ('1700'),
[wednesday] [tinyint] NOT NULL CONSTRAINT [DF_regionhours_wednesday] DEFAULT (1),
[wednesday_open_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_wednesday_open_shipping1] DEFAULT ('0800'),
[wednesday_close_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_wednesday_close_shipping1] DEFAULT ('1200'),
[wednesday_open_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_wednesday_open_receiving1] DEFAULT ('0800'),
[wednesday_close_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_wednesday_close_receiving1] DEFAULT ('1200'),
[wednesday_open_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_wednesday_open_shipping2] DEFAULT ('1300'),
[wednesday_close_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_wednesday_close_shipping2] DEFAULT ('1700'),
[wednesday_open_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_wednesday_open_receiving2] DEFAULT ('1300'),
[wednesday_close_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_wednesday_close_receiving2] DEFAULT ('1700'),
[thursday] [tinyint] NOT NULL CONSTRAINT [DF_regionhours_thursday] DEFAULT (1),
[thursday_open_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_thursday_open_shipping1] DEFAULT ('0800'),
[thursday_close_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_thursday_close_shipping1] DEFAULT ('1200'),
[thursday_open_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_thursday_open_receiving1] DEFAULT ('0800'),
[thursday_close_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_thursday_close_receiving1] DEFAULT ('1200'),
[thursday_open_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_thursday_open_shipping2] DEFAULT ('1300'),
[thursday_close_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_thursday_close_shipping2] DEFAULT ('1700'),
[thursday_open_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_thursday_open_receiving2] DEFAULT ('1300'),
[thursday_close_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_thursday_close_receiving2] DEFAULT ('1700'),
[friday] [tinyint] NOT NULL CONSTRAINT [DF_regionhours_friday] DEFAULT (1),
[friday_open_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_friday_open_shipping1] DEFAULT ('0800'),
[friday_close_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_friday_close_shipping1] DEFAULT ('1200'),
[friday_open_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_friday_open_receiving1] DEFAULT ('0800'),
[friday_close_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_friday_close_receiving1] DEFAULT ('1200'),
[friday_open_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_friday_open_shipping2] DEFAULT ('1300'),
[friday_close_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_friday_close_shipping2] DEFAULT ('1700'),
[friday_open_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_friday_open_receiving2] DEFAULT ('1300'),
[friday_close_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_friday_close_receiving2] DEFAULT ('1700'),
[saturday] [tinyint] NOT NULL CONSTRAINT [DF_regionhours_saturday] DEFAULT (0),
[saturday_open_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_saturday_open_shipping1] DEFAULT ('0000'),
[saturday_close_shipping1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_saturday_close_shipping1] DEFAULT ('0000'),
[saturday_open_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_saturday_open_receiving1] DEFAULT ('0000'),
[saturday_close_receiving1] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_saturday_close_receiving1] DEFAULT ('0000'),
[saturday_open_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_saturday_open_shipping2] DEFAULT ('0000'),
[saturday_close_shipping2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_saturday_close_shipping2] DEFAULT ('0000'),
[saturday_open_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_saturday_open_receiving2] DEFAULT ('0000'),
[saturday_close_receiving2] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_regionhours_saturday_close_receiving2] DEFAULT ('0000')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[region_hours] ADD CONSTRAINT [pk_region_hours] PRIMARY KEY NONCLUSTERED ([region_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[region_hours] TO [public]
GO
GRANT INSERT ON  [dbo].[region_hours] TO [public]
GO
GRANT REFERENCES ON  [dbo].[region_hours] TO [public]
GO
GRANT SELECT ON  [dbo].[region_hours] TO [public]
GO
GRANT UPDATE ON  [dbo].[region_hours] TO [public]
GO

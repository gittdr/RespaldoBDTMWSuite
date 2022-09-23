SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMWNotesView] as
select l.lgh_number, n.*
 from notes n with (nolock)
 join legheader l with (nolock)
 on
  (n.ntb_table='legheader' AND n.nre_tablekey = l.lgh_number)
GO
GRANT SELECT ON  [dbo].[TMWNotesView] TO [public]
GO

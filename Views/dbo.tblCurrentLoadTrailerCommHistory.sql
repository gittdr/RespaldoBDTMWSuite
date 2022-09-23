SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[tblCurrentLoadTrailerCommHistory]
as
/**
 
NAME:
dbo.tblCurrentTrailerCommHistory

TYPE:
View

DESCRIPTION:
selection of each tarilers current record on the trailerCommHistory table

Change Log: 
rwolfe init 2015/06/22

 **/
select main.trl_id, main.tch_id, main.tch_dttm, main.tch_rcvd, main.ckc_number, main.acm_system, main.tch_hooktractor,
main.tch_hook, main.tch_loadedstatus, main.tch_motionstatus, main.tch_dwellstatus, main.tch_motionsummary,
main.tch_landmarkcity, main.tch_landmarkstate, main.tch_landmarkname
from trailercommhistory main inner join
(select trl_id, Max(tch_dttm) as dttm
from trailercommhistory
group by trl_id) sub 
on sub.trl_id = main.trl_id and sub.dttm = main.tch_dttm
GO
GRANT DELETE ON  [dbo].[tblCurrentLoadTrailerCommHistory] TO [public]
GO
GRANT INSERT ON  [dbo].[tblCurrentLoadTrailerCommHistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblCurrentLoadTrailerCommHistory] TO [public]
GO
GRANT SELECT ON  [dbo].[tblCurrentLoadTrailerCommHistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblCurrentLoadTrailerCommHistory] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[branches_for_move_segments_sp]
(
@mov_number int
)
 AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.

*/

    DECLARE @ctr_country char(2)
    
    CREATE TABLE #tmp
    (
        lgh_number              int         not null,
        ord_hdrnumber           int         not null,
        ctr_branch              varchar(6)  not null,
        ctr_topup               varchar(10) not null,
        ctr_is_asso             char(1)     not null,
        lgh_primary_trailer     varchar(13) null,
        trl_branch              varchar(6)  null,
        trl_topup               varchar(10) null,
        trl_is_asso             char(1)     null,
        lgh_tractor             varchar(8)  null,
        trc_branch              varchar(6)  null,
        trc_topup               varchar(10) null,
        trc_is_asso             char(1)     null,
        associate_trc_type      varchar(3)  null,
        ctr_brn_country         char(2)     null,
        trl_brn_country         char(2)     null
    )
    
    INSERT INTO #tmp
    (
        lgh_number,
        ord_hdrnumber,
        ctr_branch,
        ctr_topup,
        ctr_is_asso,
        ctr_brn_country,
        lgh_tractor,
        lgh_primary_trailer
    )
    SELECT l.lgh_number,
        o.ord_hdrnumber,
        o.ord_revtype1,
        ISNULL(ab.payto_number,0),
        CASE WHEN ab.brn_id IS NULL THEN 'N' ELSE 'Y' END,
        bo.BRN_country_c,
        l.lgh_tractor,
        l.lgh_primary_trailer
    FROM orderheader o
            INNER JOIN legheader l ON o.mov_number = l.mov_number
            INNER JOIN branch bo ON o.ord_revtype1 = bo.brn_id
            LEFT OUTER JOIN associate_branch ab ON bo.brn_id = ab.brn_id
    WHERE o.ord_status = 'CMP'
    AND l.mov_number = @mov_number
    
    /* update the trailers */
    UPDATE #tmp
    SET trl_branch = trl.trl_terminal,
        trl_topup = ISNULL(ab.payto_number, '0'),
        trl_is_asso = CASE WHEN ab.brn_id IS NULL THEN 'N' ELSE 'Y' END,
        trl_brn_country = LEFT(btrl.brn_country_c, 3)
    FROM trailerprofile trl 
        INNER JOIN branch btrl ON trl.trl_terminal = btrl.brn_id
        LEFT OUTER JOIN associate_branch ab ON btrl.brn_id = ab.brn_id
    WHERE #tmp.lgh_primary_trailer = trl.trl_number
    AND trl.trl_number <> 'UNKNOWN'
    
    
    /* update the trailers */
    UPDATE #tmp
    SET trl_branch = 'UNK',
        trl_topup  = 'UNK',
        trl_is_asso = 'N',
        trl_brn_country = 'UN'
    WHERE lgh_primary_trailer = 'UNKNOWN'
    
    
    IF @@rowcount > 0
    BEGIN
        IF EXISTS (SELECT 1 FROM #tmp WHERE  trl_brn_country =  'UN') AND
           EXISTS (SELECT 1 FROM #tmp WHERE  trl_brn_country <> 'UN') 
        BEGIN
            UPDATE #tmp SET trl_brn_country = 
            (SELECT TOP 1 trl_brn_country FROM #tmp WHERE trl_brn_country <> 'UN')
        END
    
    END
    
    /* update the tractors */
    UPDATE #tmp
    SET trc_branch = trc.trc_terminal,
        trc_topup = ISNULL(ab.payto_number, '0'),
        trc_is_asso = CASE WHEN ab.brn_id IS NULL THEN 'N' ELSE 'Y' END,
        associate_trc_type = ISNULL(at.type, 'UNK')
    FROM tractorprofile trc 
        INNER JOIN branch btrc ON trc.trc_terminal = btrc.brn_id
        LEFT OUTER JOIN associate_branch ab ON btrc.brn_id = ab.brn_id
        LEFT OUTER JOIN associate_tractor at ON at.trc_number = trc.trc_number
    WHERE #tmp.lgh_tractor = trc.trc_number
    AND trc.trc_number <> 'UNKNOWN'
    
    /* update the tractors */
    UPDATE #tmp
    SET trc_branch = 'UNK',
        trc_topup = 'UNK',
        trc_is_asso = 'N',
        associate_trc_type = 'UNK'
    WHERE lgh_tractor = 'UNKNOWN'
    
    SELECT
        lgh_number,
        ord_hdrnumber,
        ctr_branch,
        ctr_topup,
        ctr_is_asso,
        lgh_primary_trailer,
        trl_branch,
        trl_topup,
        trl_is_asso,
        lgh_tractor,
        trc_branch,
        trc_topup,
        trc_is_asso,
        associate_trc_type,
        ctr_brn_country,
        trl_brn_country
    FROM #tmp
    
    DROP TABLE #tmp

GO
GRANT EXECUTE ON  [dbo].[branches_for_move_segments_sp] TO [public]
GO

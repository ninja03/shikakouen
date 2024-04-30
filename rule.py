def katanuki(board, kata, px, py, dir):
    kh = len(kata)
    kw = len(kata[0])
    bh = len(board)
    bw = len(board[0])

    new_board = []
    if dir == 'left':
        for y in range(bh):
            normal_buf = []
            kata_buf = []
            for x in range(bw):
                a = board[y][x]
                if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1:
                    kata_buf.append(a)
                else:
                    normal_buf.append(a)
            new_board.append(normal_buf + kata_buf)

    if dir == 'right':
        for y in range(bh):
            normal_buf = []
            kata_buf = []
            for x in range(bw):
                a = board[y][x]
                if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1:
                    kata_buf.append(a)
                else:
                    normal_buf.append(a)
            new_board.append(kata_buf + normal_buf)

    if dir == 'down':
        for x in range(bw):
            normal_buf = []
            kata_buf = []
            for y in range(bh):
                a = board[y][x]
                if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1:
                    kata_buf.append(a)
                else:
                    normal_buf.append(a)
            new_board.append(kata_buf + normal_buf)
        new_board = [[row[i] for row in new_board] for i in range(len(new_board[0]))]

    if dir == 'up':
        for x in range(bw):
            normal_buf = []
            kata_buf = []
            for y in range(bh):
                a = board[y][x]
                if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1:
                    kata_buf.append(a)
                else:
                    normal_buf.append(a)
            new_board.append(normal_buf + kata_buf)
        new_board = [[row[i] for row in new_board] for i in range(len(new_board[0]))]

    return new_board

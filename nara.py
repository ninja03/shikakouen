import copy

def print_board(board):
    for row in board:
        for cell in row:
            print(cell, end=" ")
        print()
    print()

def katanuki(board, kata, px, py, dir):
    kh = len(kata)
    kw = len(kata[0])
    bh = len(board)
    bw = len(board[0])

    new_board = []
    if dir == 'left':
        for y in range(bh):
            normal_Buf = []
            kata_buf = []
            for x in range(bw):
                a = board[y][x]
                if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1:
                    kata_buf.append(a)
                else:
                    normal_Buf.append(a)
            new_board.append(normal_Buf + kata_buf)

    if dir == 'right':
        for y in range(bh):
            normal_Buf = []
            kata_buf = []
            for x in range(bw):
                a = board[y][x]
                if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1:
                    kata_buf.append(a)
                else:
                    normal_Buf.append(a)
            new_board.append(kata_buf + normal_Buf)

    if dir == 'down':
        for x in range(bw):
            normal_Buf = []
            kata_buf = []
            for y in range(bh):
                a = board[y][x]
                if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1:
                    kata_buf.append(a)
                else:
                    normal_Buf.append(a)
            new_board.append(kata_buf + normal_Buf)
        new_board = [[row[i] for row in new_board] for i in range(len(new_board[0]))]

    if dir == 'up':
        for x in range(bw):
            normal_Buf = []
            kata_buf = []
            for y in range(bh):
                a = board[y][x]
                if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1:
                    kata_buf.append(a)
                else:
                    normal_Buf.append(a)
            new_board.append(normal_Buf + kata_buf)
        new_board = [[row[i] for row in new_board] for i in range(len(new_board[0]))]

    return new_board

if __name__ == "__main__":
    print('nara procon system')
    board = [
        [1, 0, 1, 1, 2, 2, 1],
        [2, 3, 1, 1, 0, 0, 2],
        [3, 0, 2, 1, 1, 1, 1],
        [3, 0, 0, 2, 2, 3, 1],
        [2, 2, 3, 2, 0, 2, 2],
        [3, 3, 1, 0, 3, 2, 3]
    ]

    kata = [
        [0, 1, 0],
        [1, 0, 1],
        [1, 1, 0]
    ]

    print("board")
    print_board(board)

    print("kata")
    print_board(kata)

    print('left')
    new_board = katanuki(board, kata, 1, 2, 'left')
    print_board(new_board)

    print('right')
    new_board = katanuki(board, kata, 1, 2, 'right')
    print_board(new_board)

    print('down')
    new_board = katanuki(board, kata, 1, 2, 'down')
    print_board(new_board)

    print('up')
    new_board = katanuki(board, kata, 1, 2, 'up')
    print_board(new_board)



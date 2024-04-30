import json
from rule import katanuki
from utils import print_board

if __name__ == "__main__":
    print('nara procon system')
    print()
    
    with open('question.json') as f:
        di = json.load(f)
    
    board = []
    for row in di['board']['start']:
        board.append([int(a) for a in row])

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


